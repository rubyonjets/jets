require 'digest'

module Jets::Commands
  class Build
    include StackInfo

    def initialize(options)
      @options = options.dup
    end

    def run
      puts "Building project for Lambda..."
      return if @options[:noop]
      # run gets called from the CLI and does not have all the stack_options yet.
      # We compute it and change the options early here.
      @options.merge!(stack_type: stack_type, s3_bucket: s3_bucket)
      build
    end

    def build
      build_code unless @options[:templates_only]
      build_templates
    end

    def build_code
      Jets::Builders::CodeBuilder.new.build unless @options[:noop]
    end

    def build_templates
      if @options[:stack_type] == :minimal
        build_minimal_template
      else
        build_all_templates
      end
    end

    def build_all_templates
      clean_templates
      # TODO: move this build.rb logic to cfn/builder.rb
      ## CloudFormation templates
      puts "Building Lambda functions as CloudFormation templates."
      # 1. Shared templates - child templates needs them
      build_api_gateway_templates
      # 2. Child templates - parent template needs them
      build_child_templates
      # 3. Finally parent template
      build_parent_template # must be called at the end
    end

    def build_minimal_template
      parent = Jets::Cfn::TemplateBuilders::ParentBuilder.new(@options)
      parent.build
    end

    def build_api_gateway_templates
      gateway = Jets::Cfn::TemplateBuilders::ApiGatewayBuilder.new(@options)
      gateway.build
      deployment = Jets::Cfn::TemplateBuilders::ApiGatewayDeploymentBuilder.new(@options)
      deployment.build
    end

    def build_child_templates
      app_files.each do |path|
        build_child_template(path)
      end
    end

    # path: app/controllers/comments_controller.rb
    # path: app/jobs/easy_job.rb
    def build_child_template(path)
      require "#{Jets.root}#{path}" # require "app/jobs/easy_job.rb"
      class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
      # strip the app/controller/ or app/jobs/ from the string
      # also strip the .rb
      # class_path: admin/pages_controller

      process_class = path.split('/')[1].singularize.classify # Controller or Job
      builder_class = "Jets::Cfn::TemplateBuilders::#{process_class}Builder".constantize

      # Examples:
      #   Jets::Cfn::TemplateBuilders::JobBuilder.new(EasyJob)
      #   Jets::Cfn::TemplateBuilders::ControllerBuilder.new(PostsController)
      #   Jets::Cfn::TemplateBuilders::FunctionBuilder.new(Hello)
      #   Jets::Cfn::TemplateBuilders::FunctionBuilder.new(HelloFunction)
      app_klass = Jets::Klass.from_path(path)
      builder = builder_class.new(app_klass)
      builder.build
    end

    def build_parent_template
      parent = Jets::Cfn::TemplateBuilders::ParentBuilder.new(@options)
      parent.build
    end

    def clean_templates
      FileUtils.rm_rf("#{Jets.build_root}/templates")
    end

    def app_files
      self.class.app_files
    end

    # Crucial that the Dir.pwd is in the tmp_app_root because for
    # because Jets.boot set ups autoload_paths and this is how project
    # classes are loaded.
    def self.app_files
      paths = []
      expression = "#{Jets.root}app/**/**/*.rb"
      Dir.glob(expression).each do |path|
        return false unless File.file?(path)
        next unless app_file?(path)

        relative_path = path.sub(Jets.root.to_s, '')
        # Rids of the Jets.root at beginning
        paths << relative_path
      end
      paths
    end

    def self.app_file?(path)
      return false unless File.extname(path) == ".rb"
      # Do not define lamda functions for the application_controller.rb or
      # application_job.rb
      excludes = %w[
        application_controller.rb
        application_job.rb
      ]
      return false if excludes.detect { |p| path.include?(p) }

      includes = %w[
        app/controllers
        app/jobs
        app/functions
      ]
      return true if includes.detect { |p| path.include?(p) }

      false
    end

    def self.tmp_app_root(full_build_path=false)
      full_build_path ? "#{Jets.build_root}/app_root" : "app_root"
    end

  end
end
