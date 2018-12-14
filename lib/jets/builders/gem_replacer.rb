class Jets::Builders
  class GemReplacer
    extend Memoist
    def initialize(ruby_version, options)
      @ruby_version = ruby_version
      @options = options
    end

    def run
      check = Jets::Gems::Check.new
      found_gems = check.run! # exits early if missing gems found

      # Reaching here means its safe to download and extract the gems
      found_gems.each do |gem_name, source|
        options = @options.merge(source_url: source)
        gem_extractor = Jets::Gems::Extract::Gem.new(gem_name, options)
        gem_extractor.run
      end

      # At this point the current compiled gems have been removed and compiled gems
      # have been unpacked to code/opt. We can take the unpacked gems in opt and fully
      # move them into vendor/bundle gems now.
      move_opt_gems_to_vendor

      tidy
    end

    def move_opt_gems_to_vendor
      code = "#{Jets.build_root}/stage/code"
      opt_gems = "#{code}/opt/ruby/gems/#{Jets::Gems.ruby_folder}"
      vendor_gems = "#{code}/vendor/bundle/ruby/#{Jets::Gems.ruby_folder}"
      # https://stackoverflow.com/questions/23698183/how-to-force-cp-to-overwrite-directory-instead-of-creating-another-one-inside
      # $ cp -TRv foo/ bar/
      sh "cp -TR #{opt_gems} #{vendor_gems}"
      # clean up opt compiled gems
      FileUtils.rm_rf("#{code}/opt/ruby")
    end

    def sh(command)
      puts "=> #{command}".colorize(:green)
      success = system(command)
      abort("Command Failed") unless success
      success
    end

    # remove unnecessary files to reduce package size
    def tidy
      # project_root: /tmp/jets/demo/stage/code/
      # /tmp/jets/demo/stage/code/bundled
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
