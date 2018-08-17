# def extract_gems
#   headline "Replacing compiled gems with Lambda Linux versions."
#   Lambdagem::Extract::Gem.new(Jets::RUBY_VERSION,
#     s3: "lambdagems",
#     dest: full(cache_area),
#   ).run
# end
class Jets::Builders
  class GemReplacer
    extend Memoist
    attr_reader :missing_gems
    def initialize(ruby_version, options)
      @ruby_version = ruby_version
      @options = options
      @missing_gems = [] # keeps track of gems that are not found in any of the lambdagems sources
    end

    def run
      # Checks whether the gem is found on at least one of the lambdagems sources.
      # By the time the loop finishes, found_gems will hold a map of gem names to found
      # url sources. Example:
      #
      #   found_gems = {
      #     "nokogiri-1.8.4" => "https://lambdagems.com",
      #     "pg-0.21.0" => "https://anothersource.com",
      #   }
      #
      found_gems = {}
      compiled_gems.each do |gem_name|
        gem_exists = false
        Jets.config.lambdagems.sources.each do |source|
          exist = Lambdagem::Exist.new(lambdagems_url: source)
          found = exist.check(gem_name)
          # gem exists on at least of the lambdagem sources
          if found
            gem_exists = true
            found_gems[gem_name] = source
            break
          end
        end
        unless gem_exists
          @missing_gems << gem_name
        end
      end

      # Exits early if not all the linux gems are available.
      # It better to error now than deploy a broken package to AWS Lambda.
      # Provide users with message about using their own lambdagems source.
      unless @missing_gems.empty?
        puts missing_gems_message
        exit 1
      end

      # Reaching here means we can download and extract the gems
      Lambdagem.log_level = :info
      found_gems.each do |gem_name, source|
        gem_extractor = Lambdagem::Extract::Gem.new(gem_name, @options.merge(lambdagems_url: source))
        gem_extractor.run
      end

      tidy
    end

    def missing_gems_message
      template = <<-EOL
Your project requires compiled gems were not available in any of your lambdagems sources.  Unavailable pre-compiled gems:
<% missing_gems.each do |gem| %>
* <%= gem -%>
<% end %>

Your current lambdagems sources:
<% Jets.config.lambdagems.sources.map do |source| %>
* <%= source -%>
<% end %>

Jets is unable to build a deployment package that will work on AWS Lambda without the required pre-compiled gems. To remedy this, you can:

* Build the gem yourself and add it to your own custom lambdagems sources. Refer to the Lambda Gems Docs: http://rubyonjets.com/docs/lambdagems
* Wait until it added to lambdagems.com. No need to report this to us, as we've already been notified.
* Use another gem that does not require compilation.

Compiled gems usually take some time to figure out how to build as they each depend on different libraries and packages. We make an effort add new gems as soon as we can. You can support us by going to: http://rubyonjets.com/support-jets/
EOL
      erb = ERB.new(template, nil, '-') # trim mode https://stackoverflow.com/questions/4632879/erb-template-removing-the-trailing-line
      erb.result(binding)
    end

    # remove unnecessary files to reduce package size
    def tidy
      tidy_gems("#{@options[:project_root]}/bundled/gems/ruby/*/gems/*")
      tidy_gems("#{@options[:project_root]}/bundled/gems/ruby/*/bundler/gems/*")
    end

    def tidy_gems(gems_path)
      Dir.glob(gems_path).each do |gem_path|
        tidy_gem(gem_path)
      end
    end

    # Clean up some unneeded files to try to keep the package size down
    # In a generated jets app this made a decent 9% difference:
    #  175M test2
    #  191M test3
    def tidy_gem(path)
      # remove top level tests and cache folders
      Dir.glob("#{path}/*").each do |path|
        next unless File.directory?(path)
        folder = File.basename(path)
        if %w[test tests spec features benchmark cache doc].include?(folder)
          FileUtils.rm_rf(path)
        end
      end

      Dir.glob("#{path}/**/*").each do |path|
        next unless File.file?(path)
        ext = File.extname(path)
        if %w[.rdoc .md .markdown].include?(ext) or
           path =~ /LICENSE|CHANGELOG|README/
          FileUtils.rm_f(path)
        end
      end
    end

    # If there are subfolders compiled_gem_paths might have files deeper
    # in the directory tree.  So lets grab the gem name and figure out the
    # unique paths of the compiled gems from there.
    def compiled_gems
      compiled_gem_paths.map { |p| gem_name_from_path(p) }.uniq# + ["whatever-0.0.1"]
    end
    memoize :compiled_gems

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
