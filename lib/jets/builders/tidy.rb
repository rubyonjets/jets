module Jets::Builders
  class Tidy
    include Util

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

      clean_vendor_gems
      clean_webpack_assets
    end

    # Clean out unnecessary src and compiled packs because Jets serves them out of s3.
    # This keeps the code size down to help keep it in size limit so we can use the
    # live Lambda console editor.
    def clean_webpack_assets
      FileUtils.rm_rf("#{@project_root}/app/javascript/src")

      return unless File.exist?("#{@project_root}/public/packs") # this class works for rack subfolder too
      FileUtils.mv("#{@project_root}/public/packs/manifest.json", "#{stage_area}/manifest.json")
      FileUtils.rm_rf("#{@project_root}/public/packs")
      FileUtils.mkdir_p("#{@project_root}/public/packs")
      FileUtils.mv("#{stage_area}/manifest.json", "#{@project_root}/public/packs/manifest.json")
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
      always = %w[.bundle packs vendor]
      path = "#{@project_root}/.jetskeep"
      return always unless File.exist?(path)

      keep = IO.readlines(path)
      keep = keep.map {|i| i.strip}.reject { |i| i =~ /^#/ || i.empty? }
      (always + keep).uniq
    end

    # folders to remove in the vendor/gems folder regardless of the level of the folder
    def clean_vendor_gems
      # Thanks: https://stackoverflow.com/questions/11385795/ruby-list-directory-with-dir-including-dotfiles-but-not-and
      Dir.glob("#{@project_root}/vendor/gems/**/*", File::FNM_DOTMATCH).each do |path|
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
      cache_path = "#{@project_root}/vendor/gems/ruby/#{Jets.ruby_folder}/cache"
      FileUtils.rm_rf(cache_path)
    end

    def rm_rf(path)
      exists = File.exist?("#{path}/.gitkeep") || File.exist?("#{path}/.keep")
      return if exists

      # say "  rm -rf #{path}".color(:yellow) # uncomment to debug
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