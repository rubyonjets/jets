module Jets::Commands
  class Gems < Jets::Commands::Base
    desc "check", "Check pre-built Lambda gem is available in the sources"
    long_desc Help.text(:check)
    def check
      # gem_name = "pg-0.21.0"
      # options = {
      #   :s3=>"lambdagems",
      #   :build_root=>"/tmp/jets/demo/cache",
      #   :project_root=>"/tmp/jets/demo/stage/code"}
      # source = "https://gems.lambdagems.com"
      # gem_extractor = Jets::Gems::Extract::Gem.new(gem_name, options.merge(source_url: source))
      # gem_extractor.run



      # Jets::Gems::Check.new(options).run
    end
  end
end
