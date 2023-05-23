# frozen_string_literal: true

module Jets
  module Command
    module Actions
      # Change to the application's path if there is no <tt>config.ru</tt> file in current directory.
      # This allows us to run <tt>jets server</tt> from other directories, but still get
      # the main <tt>config.ru</tt> and properly set the <tt>tmp</tt> directory.
      def set_application_directory!
        Dir.chdir(File.expand_path("../..", APP_PATH)) unless File.exist?(File.expand_path("config.ru"))
      end

      def require_application_and_environment!
        Jets.boot
      end

      def require_application!
        require ENGINE_PATH if defined?(ENGINE_PATH)

        if defined?(APP_PATH)
          require APP_PATH
        end
      end

      if defined?(ENGINE_PATH)
        def load_tasks
          Rake.application.init("jets")
          Rake.application.load_rakefile
        end

        def load_generators
          engine = ::Jets::Engine.find(ENGINE_ROOT)
          Jets::Generators.namespace = engine.railtie_namespace
          engine.load_generators
        end
      else
        def load_tasks
          Jets.boot # hack
          Jets.application.load_tasks
        end

        def load_generators
          Jets.application.load_generators
        end
      end
    end
  end
end

