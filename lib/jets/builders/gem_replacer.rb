class Jets::Builders
  class GemReplacer
    extend Memoist
    def initialize(ruby_version, options)
      @ruby_version = ruby_version
      @options = options
    end

    def run
      check = Jets::Gems::Check.new
      found_gems = check.run
      if check.missing?
        # Exits early if not all the linux gems are available.
        # Better to error now than deploy a broken package to AWS Lambda.
        # Provide users with message about using their own lambdagems source.
        puts check.missing_message
        Jets::Gems::Report.missing(check.missing_gems)
        exit 1
      end

      # Reaching here means its safe to download and extract the gems
      found_gems.each do |gem_name, source|
        options = @options.merge(source_url: source)
        gem_extractor = Jets::Gems::Extract::Gem.new(gem_name, options)
        gem_extractor.run
      end

      tidy
    end

    def report_missing_gems

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
  end
end
