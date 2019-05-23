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
      build_code unless @options[:templates]
      build_templates
    end

    def build_code
      Jets::Builders::CodeBuilder.new.build unless @options[:noop]
    end

    def build_templates
      puts "Building CloudFormation templates."
      clean_templates
      build_minimal_template
      build_all_templates if full?
    end

    def full?
      @options[:templates] || @options[:stack_type] == :full
    end

    def build_all_templates
      # CloudFormation templates
      # 1. Shared templates - child templates needs them
      build_api_gateway_templates
      # 2. Child templates - parent template needs them
      build_app_child_templates
      # 2. Child templates - parent template needs them
      build_shared_resources_templates
      # 4. Finally parent template
      build_parent_template # must be called at the end
    end

    def build_minimal_template
      Jets::Cfn::Builders::ParentBuilder.new(@options).build
    end

    def build_api_gateway_templates
      Jets::Cfn::Builders::ApiGatewayBuilder.new(@options).build
      Jets::Cfn::Builders::ApiDeploymentBuilder.new(@options).build
    end

    def build_app_child_templates
      app_files.each do |path|
        build_child_template(path)
      end
    end

    def build_shared_resources_templates
      Jets::Stack.subclasses.each do |subclass|
        Jets::Cfn::Builders::SharedBuilder.new(subclass).build
      end
    end

    # path: app/controllers/comments_controller.rb
    # path: app/jobs/easy_job.rb
    def build_child_template(path)
      md = path.match(%r{app/(.*?)/}) # extract: controller, job or function
      process_class = md[1].classify
      builder_class = "Jets::Cfn::Builders::#{process_class}Builder".constantize

      # Examples:
      #   Jets::Cfn::Builders::ControllerBuilder.new(PostsController)
      #   Jets::Cfn::Builders::JobBuilder.new(EasyJob)
      #   Jets::Cfn::Builders::RuleBuilder.new(CheckRule)
      #   Jets::Cfn::Builders::FunctionBuilder.new(Hello)
      #   Jets::Cfn::Builders::FunctionBuilder.new(HelloFunction)
      app_class = Jets::Klass.from_path(path)
      builder = builder_class.new(app_class)
      unless Jets.poly_only? && app_class == Jets::PreheatJob
        builder.build
      end
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

    # Crucial that the Dir.pwd is in the tmp_code because for
    # because Jets.boot set ups autoload_paths and this is how project
    # classes are loaded.
    # TODO: rework code so that Dir.pwd does not have to be in tmp_code for build to work.
    def self.app_files
      paths = []
      expression = "#{Jets.root}/app/**/**/*.rb"
      Dir.glob(expression).each do |path|
        return false unless File.file?(path)
        next unless app_file?(path)
        next if concerns?(path)

        relative_path = path.sub("#{Jets.root}/", '')
        # Rids of the Jets.root at beginning
        paths << relative_path
      end
      paths += internal_app_files
      paths
    end

    def shared_files
      self.class.shared_files
    end

    def self.shared_files
      paths = []
      expression = "#{Jets.root}/app/**/**/*.rb"
      Dir.glob(expression).each do |path|
        return false unless File.file?(path)
        next unless path.include?("app/shared/resources")

        relative_path = path.sub("#{Jets.root}/", '')
        # Rids of the Jets.root at beginning
        paths << relative_path
      end
      paths
    end

    # Finds out of the app has polymorphic functions only and zero ruby functions.
    # In this case, we can skip a lot of the ruby related building and speed up the
    # deploy process.
    def self.poly_only?
      !app_has_ruby? && !shared_has_ruby?
    end

    def self.app_has_ruby?
      has_ruby = app_files.detect do |path|
        app_class = Jets::Klass.from_path(path)  # IE: PostsController, Jets::PublicController
        langs = app_class.tasks.map(&:lang)
        langs.include?(:ruby) && app_class != Jets::PreheatJob
      end
      !!has_ruby
    end

    def self.shared_has_ruby?
      has_ruby = false
      Jets::Stack.subclasses.each do |klass|
        klass.functions.each do |fun|
          if fun.lang == :ruby
            has_ruby = true
            break
          end
        end
      end
      has_ruby
    end

    # Add internal Jets controllers if they are being used
    # TODO: Interesting, this eventually just used to generate handlers and controllers only.
    # Maybe rename to make that clear.
    # The copying of other internal files like views is done in builders/code_builder.rb copy_internal_jets_code
    def self.internal_app_files
      paths = []
      controllers = File.expand_path("../../internal/app/controllers/jets", __FILE__)

      public_catchall = Jets::Router.has_controller?("Jets::PublicController")
      paths << "#{controllers}/public_controller.rb" if public_catchall

      rack_catchall = Jets::Router.has_controller?("Jets::RackController")
      paths << "#{controllers}/rack_controller.rb" if rack_catchall

      mailer_controller = Jets::Router.has_controller?("Jets::MailersController")
      paths << "#{controllers}/mailers_controller.rb" if mailer_controller

      if Jets.config.prewarm.enable
        jobs = File.expand_path("../../internal/app/jobs/jets", __FILE__)
        paths << "#{jobs}/preheat_job.rb"
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
        app/rules
      ]
      return true if includes.detect { |p| path.include?(p) }

      false
    end

    def self.concerns?(path)
      path =~ %r{app/\w+/concerns/}
    end

    def self.tmp_code(full_build_path=false)
      full_build_path ? "#{Jets.build_root}/stage/code" : "stage/code"
    end

  end
end
