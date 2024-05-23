module Jets
  class Framework
    class << self
      extend Memoist
      def env_var
        "#{name.upcase}_ENV" if name # can be nil
      end

      def env
        return unless env_var
        ENV[env_var] || "production" # for Dockerfile default to production
      end

      def name
        gems.each do |gem|
          frameworks.each do |framework|
            if gem == framework
              # Special case for puma. If puma is detected, it means it is a rack app.
              if framework == "puma"
                return "rack"
              else
                return framework
              end
            end
          end
        end
        nil
      end
      memoize :name

      def frameworks
        %w[
          rails
          sinatra
          hanami
          rack
          puma
        ]
      end

      def gems
        return [] unless File.exist?("Gemfile")
        Bundler.with_unbundled_env do
          gemfile_content = File.read("Gemfile")
          dsl = Bundler::Dsl.evaluate(Bundler.default_gemfile, gemfile_content, {})
          dsl.dependencies.map(&:name)
        end
      end
    end
  end
end
