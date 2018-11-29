class Jets::Builders
  class Tidy
    def initialize(project_root, noop: false)
      @project_root = project_root
      @noop = noop
    end

    def cleanup!
      removals.each do |removal|
        removal = removal.sub(%r{^/},'') # remove leading slash
        path = "#{@project_root}/#{removal}"
        rm_rf(path)
      end

      tidy_bundled
    end

    def removals
      removals = always_removals
      removals += get_removals("#{@project_root}/.gitignore")
      removals += get_removals("#{@project_root}/.dockerignore")
      removals = removals.reject do |p|
        jetskeep.find do |keep|
          p.include?(keep)
        end
      end
      removals.uniq
    end

    def get_removals(file)
      path = file
      return [] unless File.exist?(path)

      removal = File.read(path).split("\n")
      removal.map {|i| i.strip}.reject {|i| i =~ /^#/ || i.empty?}
      # IE: ["/handlers", "/bundled*", "/vendor/jets]
    end

    # We clean out ignored files pretty aggressively. So provide
    # a way for users to keep files from being cleaned out.
    def jetskeep
      defaults = %w[.bundle bundled pack handlers public/assets]
      path = "#{@project_root}/.jetskeep"
      return defaults unless File.exist?(path)

      keep = IO.readlines(path)
      keep = keep.map {|i| i.strip}.reject { |i| i =~ /^#/ || i.empty? }
      (defaults + keep).uniq
    end

    # folders to remove in the vendor/bundle folder regardless of the level of the folder
    def tidy_bundled
      Dir.glob("#{@project_root}/vendor/bundle/**/*").each do |path|
        next unless File.directory?(path)
        dir = File.basename(path)
        next unless always_removals.include?(dir)

        rm_rf(path)
      end

      remove_gem_cache
    end

    # Reason do not remove the cache folder generally is because some gems have
    # actual cache folders that they used.
    def remove_gem_cache
      ruby_minor_version = Jets::RUBY_VERSION.split('.')[0..1].join('.') + '.0'
      cache_path = "#{@project_root}/vendor/bundle/ruby/#{ruby_minor_version}/cache"
      FileUtils.rm_rf(cache_path)
    end

    def rm_rf(path)
      exists = File.exist?("#{path}/.gitkeep") || File.exist?("#{path}/.keep")
      return if exists

      # say "  rm -rf #{path}".colorize(:yellow) # uncomment to debug
      system("rm -rf #{path}") unless @noop
    end

    # These directories will be removed regardless of dir level
    def always_removals
      %w[.git spec tmp]
    end

    def say(message)
      message = "NOOP #{message}" if @noop
      puts message
    end
  end
end