module Jets
  class Autoloaders
    # for jets gem itself
    class Gem
      class << self
        extend Memoist

        def loader
          loader = Zeitwerk::Loader.new
          loader.tag = "jets.gem"
          loader.inflector = Inflector.new
          loader.push_dir(lib)
          loader.do_not_eager_load(do_not_eager_load)
          loader.ignore(ignore_paths) # loader.ignore requires full dir or path
          # loader.log!
          loader
        end
        memoize :loader

        def setup
          loader.setup
        end

        def lib
          File.expand_path("#{__dir__}/../..") # jets/lib
        end

        def do_not_eager_load
          paths = %w[]
          paths.map { |path| "#{lib}/#{path}" } # do_not_eager_load requires full dir or path
        end

        def ignore_paths
          # commands
          paths = %w[
            jets/cli/generate/templates
            jets/cli/init/templates
            jets/core_ext
            jets/core_ext.rb
            jets/overrides
            jets/shim/template
          ]
          paths.map { |path| "#{lib}/#{path}" }
        end
      end

      class Inflector < Zeitwerk::Inflector
        def camelize(basename, _abspath)
          map = {
            cli: "CLI",
            io: "IO",
            version: "VERSION"
          }
          map[basename.to_sym] || super
        end
      end
    end
  end
end
