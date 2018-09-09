require 'digest'

module Jets::Commands
  class Build
    include Jets::Timing
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
    time :run

    def build
      build_code unless @options[:templates_only]
      build_templates
    end
    time :build

    def build_code
      Jets::Builders::CodeBuilder.new.build unless @options[:noop]
    end
    time :build_code

    def build_templates
      if @options[:stack_type] == :minimal
        build_minimal_template
      else
        build_all_templates
      end
    end
    time :build_templates

    def build_all_templates
      clean_templates
      # CloudFormation templates
      # 1. Shared templates - child templates needs them
      build_api_gateway_templates
      # 2. Child templates - parent template needs them
      build_child_templates
      # 3. Finally parent template
      build_parent_template # must be called at the end
    end

    def build_minimal_template
      Jets::Cfn::Builders::ParentBuilder.new(@options).build
    end

    def build_api_gateway_templates
      Jets::Cfn::Builders::ApiGatewayBuilder.new(@options).build
      Jets::Cfn::Builders::ApiDeploymentBuilder.new(@options).build
    end

    def build_child_templates
      app_files.each do |path|
        build_child_template(path)
      end
    end

    # path: app/controllers/comments_controller.rb
    # path: app/jobs/easy_job.rb
    def build_child_template(path)
      class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
      class_name = class_path.classify
      class_name.constantize # load app/**/* class definition

      md = path.match(%r{app/(.*?)/}) # extract: controller, job or function
      process_class = md[1].classify
      builder_class = "Jets::Cfn::Builders::#{process_class}Builder".constantize

      # Examples:
      #   Jets::Cfn::Builders::ControllerBuilder.new(PostsController)
      #   Jets::Cfn::Builders::JobBuilder.new(EasyJob)
      #   Jets::Cfn::Builders::RuleBuilder.new(CheckRule)
      #   Jets::Cfn::Builders::FunctionBuilder.new(Hello)
      #   Jets::Cfn::Builders::FunctionBuilder.new(HelloFunction)
      app_klass = Jets::Klass.from_path(path)
      builder = builder_class.new(app_klass)
      builder.build
    end

    def build_parent_template
      Jets::Cfn::Builders::ParentBuilder.new(@options).build
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
    # TODO: rework code so that Dir.pwd does not have to be in tmp_app_root for build to work.
    def self.app_files
      paths = []
      expression = "#{Jets.root}app/**/**/*.rb"
      Dir.glob(expression).each do |path|
        return false unless File.file?(path)
        next if path.include?("app/functions") # cannot lazy load these because they are anonymous classes
        next unless app_file?(path)

        relative_path = path.sub(Jets.root.to_s, '')
        # Rids of the Jets.root at beginning
        paths << relative_path
      end
      paths += internal_app_files
      paths
    end

    def self.poly_only?
      # Scans all the app code and look for any methods that are ruby.
      # If any method is written in ruby then we know the app is not a
      # soley polymorphic non-ruby app.
      has_ruby = app_files.detect do |path|
        # 1. remove app/controllers or app/jobs, etc
        # 2. remove .rb extension
        app_file = path.sub(%r{app/\w+/},'').sub(/\.rb$/,'')
        # Internal jets controllers like Welcome and Public need a different regexp
        app_file = app_file.sub(%r{.*lib/jets/internal/},'')
        app_klass = app_file.classify.constantize # IE: PostsController, Jets::PublicController
        langs = app_klass.tasks.map(&:lang)
        langs.include?(:ruby)
      end
      !has_ruby
    end

    # Add internal Jets controllers if they are being used
    def self.internal_app_files
      paths = []
      controllers = File.expand_path("../../internal/app/controllers/jets", __FILE__)

      welcome = Jets::Router.has_controller?("Jets::WelcomeController")
      paths << "#{controllers}/welcome_controller.rb" if welcome

      public_catchall = Jets::Router.has_controller?("Jets::PublicController")
      paths << "#{controllers}/public_controller.rb" if public_catchall

      jobs = File.expand_path("../../internal/app/jobs/jets", __FILE__)
      paths << "#{jobs}/preheat_job.rb"

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
        app/rules
      ]
      return true if includes.detect { |p| path.include?(p) }

      false
    end

    def self.tmp_app_root(full_build_path=false)
      full_build_path ? "#{Jets.build_root}/app_root" : "app_root"
    end

  end
end
