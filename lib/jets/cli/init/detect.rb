class Jets::CLI::Init
  class Detect
    def framework
      gems.each do |gem|
        frameworks.each do |framework|
          return framework if gem == framework
        end
      end
      nil
    end

    def frameworks
      %w[
        rails
        sinatra
        hanami
        grape
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
