require "zeitwerk"

module Jets
  class Autoloaders
    class GemInflector < Zeitwerk::Inflector
      def camelize(basename, _abspath)
        map = {
          cli: "CLI",
          io: "IO",
          version: "VERSION"
        }
        map[basename.to_sym] || super
      end
    end

    # for jets gem itself
    class Gem
      def autoloader
        loader = Zeitwerk::Loader.new
        loader.tag = "jets.gem"
        loader.inflector = GemInflector.new
        loader.push_dir(lib)
        loader.do_not_eager_load(do_not_eager_load)
        loader.ignore(ignore_paths) # loader.ignore requires full dir or path
        # loader.log!
        loader
      end

      def lib
        File.expand_path("#{__dir__}/../..") # jets/lib
      end

      # For jets/info.rb see Jets::Info property Middleware for why we do not eager load.
      def do_not_eager_load
        paths = %w[
          jets/info.rb
          jets/spec_helpers
          jets/spec_helpers.rb
          jets/commands
          jets/commands.rb
          jets/generators
          jets/generators.rb
        ]
        paths.map { |path| "#{lib}/#{path}" } # do_not_eager_load requires full dir or path
      end

      def ignore_paths
        # commands
        paths = %w[
          jets/application/dummy_config.rb
          jets/application/dummy_erb_compiler.rb
          jets/builders/rackup_wrappers
          jets/builders/templates
          jets/commands/templates
          jets/controller/middleware/webpacker_setup.rb
          jets/core_ext
          jets/core_ext.rb
          jets/generator
          jets/overrides
          jets/ruby_version_check.rb
          jets/cli.rb
          jets/commands.rb
          jets/generators/jets/app/ignore
          jets/tasks.rb
        ]
        paths.map { |path| "#{lib}/#{path}" }
      end
    end
  end
end
