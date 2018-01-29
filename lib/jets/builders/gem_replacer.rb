# def extract_gems
#   headline "Replacing compiled gems with Lambda Linux versions."
#   Lambdagem::Extract::Gem.new(JETS_RUBY_VERSION,
#     build_root: full(cache_area),
#     s3: "lambdagems",
#     dest: full(cache_area),
#   ).run
# end
class Jets::Builders
  class GemReplacer
    def initialize(ruby_version, options)
      @ruby_version = ruby_version
      @options = options
    end

    def run
      # If there are subfolders compiled_gem_paths might have files deeper
      # in the directory tree.  So lets grab the gem name and figure out the
      # unique paths of the compiled gems from there.
      gem_names = compiled_gem_paths.map { |p| gem_name_from_path(p) }.uniq

      # Exits early if not all the linux gems are available
      # It better to error now then later on Lambda
      # Provide users with instructions on how to compile gems
      # TODO: set lambdagems_url from config/application.rb.
      exist = Lambdagem::Exist.new(lambdagems_url: Jets.config.lambdagems_url)
      exist.check(gem_names)

      gem_names.each do |gem_name|
        gem_extractor = Lambdagem::Extract::Gem.new(gem_name, @options)
        gem_extractor.run
      end
    end

    def cache_area
      "#{Jets.build_root}/cache" # cleaner to use full path for this setting
    end

    # Use pre-compiled gem because the gem could have development header shared
    # object file dependencies.  The shared dependencies are packaged up as part
    # of the pre-compiled gem so it is available in the Lambda execution environment.
    #
    # Example paths:
    # Macosx:
    #   bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/nokogiri-1.8.1
    #   bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
    # Official AWS Lambda Linux AMI:
    #   bundled/gems/ruby/2.5.0/extensions/x86_64-linux/2.5.0-static/nokogiri-1.8.1
    # Circleci Ubuntu based Linux:
    #   bundled/gems/ruby/2.5.0/extensions/x86_64-linux/2.5.0/pg-0.21.0
    def compiled_gem_paths
      Dir.glob("#{Jets.build_root}/cache/bundled/gems/ruby/*/extensions/**/**/*.{so,bundle}")
    end

    # Input: bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
    # Output: byebug-9.1.0
    def gem_name_from_path(path)
      regexp = /gems\/ruby\/\d+\.\d+\.\d+\/extensions\/.*?\/.*?\/(.*?)\//
      gem_name = path.match(regexp)[1]
    end
  end
end
