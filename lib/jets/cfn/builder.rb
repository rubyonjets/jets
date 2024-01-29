module Jets::Cfn
  class Builder
    extend Memoist
    include Jets::AwsServices

    def initialize(options)
      @options = options
    end

    def build
      puts "Building CloudFormation templates"
      clean_templates
      build_minimal_parent_template
      if @options[:stack_type] == :full
        build_all_templates
        build_full_parent_template # must be called at the end
      end
      Jets::Router::State.save_apigw_state if ENV['JETS_API_STATE_DEBUG']
      puts "Built CloudFormation templates at #{Jets.build_root}/templates"
    end

    def build_minimal_parent_template
      Parent.new(@options.merge(stack_type: :minimal)).build
    end

    def build_all_templates
      # CloudFormation templates
      # 1. Shared and authorizer templates - child templates needs them
      build_api_gateway_templates unless Jets::Router.no_routes?
      build_authorizer_templates # controllers can use these
      # 2. Child templates - parent template needs them
      build_one_lambda_for_all_controllers
      build_app_child_templates
      # 3. Child templates - parent template needs them
      build_shared_resources_templates
    end

    def build_full_parent_template
      Parent.new(@options.merge(stack_type: :full)).build
    end

    def build_api_gateway_templates
      Api::Gateway.new(@options).build
      Api::Resources.build_pages(@options)
      Api::Methods.build_pages(@options)
      Api::Deployment.new(@options).build
      Api::Mapping.new(@options).build
    end

    def build_authorizer_templates
      authorizer_files.each do |path|
        Authorizer.new(path).build
      end
    end

    def build_one_lambda_for_all_controllers
      return if Jets.config.mode == "job"
      return unless Jets.one_lambda_for_all_controllers?
      OneController.new(@options).build
    end

    def build_app_child_templates
      app_files.each do |path|
        build_child_template(path)
      end
    end

    def build_shared_resources_templates
      Jets::Stack.subclasses.each do |subclass|
        Shared.new(subclass).build
      end
    end

    # path: app/controllers/comments_controller.rb
    # path: app/jobs/easy_job.rb
    def build_child_template(path)
      return if authorizer?(path) # AuthorizerBuilder is built earlier

      md = path.match(%r{app/(.*?)/}) # extract: controller, job or function
      app_class = md[1].classify

      if app_class == "Controller" && Jets.one_lambda_for_all_controllers? # app/controllers
        return
      end

      builder_class = "Jets::Cfn::Builder::#{app_class}".constantize

      app_class = Jets::Klass.from_path(path)
      if !Jets.gem_layer? && app_class == Jets::PreheatJob
        return # No prewarm when there's only poly functions and no gem layer
      end

      # Builder class fully qualified name:
      #   Controller => Jets::Cfn::Builder::Controller
      # Examples:
      #   Controller.new(PostsController).build
      #   Job.new(EasyJob).build
      #   Rule.new(CheckRule).build
      #   Function.new(Hello).build
      #   Function.new(HelloFunction).build
      builder_class.new(app_class).build
    end

    def authorizer?(path)
      path.include?("app/authorizers")
    end

    def clean_templates
      FileUtils.rm_rf("#{Jets.build_root}/templates")
    end

    def app_files
      self.class.app_files
    end

    def shared_files
      self.class.shared_files
    end

    def authorizer_files
      self.class.authorizer_files
    end

    class << self
      # Crucial that the Dir.pwd is in the tmp_code because for because Jets.boot set ups autoload_paths and this is
      # how project classes are loaded.
      # TODO: rework code so that Dir.pwd does not have to be in tmp_code for build to work.
      #
      # app_files used to determine what CloudFormation templates to build.
      # app_files also used to determine what handlers to build.
      def app_files
        paths = []
        expression = "#{Jets.root}/app/**/**/*.rb"
        Dir.glob(expression).each do |path|
          next unless app_file?(path)
          relative_path = path.sub("#{Jets.root}/", '') # rid of the Jets.root at beginning
          paths << relative_path
        end

        if Jets.config.prewarm.enable
          internal = File.expand_path("../internal", __dir__)
          paths << "#{internal}/app/jobs/jets/preheat_job.rb"
        end

        paths
      end

      APP_FOLDERS = %w[authorizers controllers functions jobs rules]
      def app_file?(path)
        return false unless File.extname(path) == ".rb"
        return false unless File.file?(path) unless Jets.env.test?
        return false if application_abstract_classes.detect { |p| path.include?(p) }
        return false if concerns?(path)
        return true if APP_FOLDERS.detect { |p| path.include?("app/#{p}") }
        false
      end

      # Do not define lamda functions for abstract application parent classes. Examples:
      #
      #   application_controller.rb
      #   application_job.rb
      #   application_authorizer.rb
      def application_abstract_classes
        APP_FOLDERS.map { |a| "application_#{a.singularize}.rb" }
      end

      def concerns?(path)
        path =~ %r{app/\w+/concerns/}
      end

      def authorizer_files
        app_files.select { |p| p.include?("app/authorizers") }
      end

      def shared_files
        find_app_paths("shared/resources")
      end

      def find_app_paths(app_path)
        paths = []
        expression = "#{Jets.root}/app/#{app_path}/**/*.rb"
        Dir.glob(expression).each do |path|
          return false unless File.file?(path)

          relative_path = path.sub("#{Jets.root}/", '')
          # Rids of the Jets.root at beginning
          paths << relative_path
        end
        paths
      end

      # Finds out of the app has polymorphic functions only and zero ruby functions.
      # In this case, we can skip a lot of the ruby related building and speed up the
      # deploy process.
      def poly_only?
        !app_has_ruby? && !shared_has_ruby?
      end

      def app_has_ruby?
        has_ruby = app_files.detect do |path|
          app_class = Jets::Klass.from_path(path)  # IE: PostsController, Jets::PublicController
          langs = app_class.definitions.map(&:lang)
          langs.include?(:ruby) && app_class != Jets::PreheatJob
        end
        !!has_ruby
      end

      def shared_has_ruby?
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

      def router_has?(controller)
        Jets::Router.has_controller?(controller)
      end

      def tmp_code(full_build_path=false)
        full_build_path ? "#{Jets.build_root}/stage/code" : "stage/code"
      end
    end
  end
end
