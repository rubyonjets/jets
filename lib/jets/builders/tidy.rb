class Jets::Builders
  class Tidy
    def initialize(project_root)
      @project_root = project_root
    end

    def cleanup!
      excludes.each do |exclude|
        exclude = exclude.sub(%r{^/},'') # remove leading slash
        remove_path = "#{@project_root}/#{exclude}"
        puts "  rm -rf #{remove_path}".colorize(:yellow) # uncomment to debug
        FileUtils.rm_rf(remove_path)
      end

      tidy_bundled
    end

    def excludes
      excludes = default_excludes
      excludes += get_excludes("#{@project_root}/.gitignore")
      excludes += get_excludes("#{@project_root}/.dockerignore")
      excludes = excludes.reject do |p|
        jetskeep.find do |keep|
          p.include?(keep)
        end
      end
      excludes
    end

    def get_excludes(file)
      path = file
      return [] unless File.exist?(path)

      exclude = File.read(path).split("\n")
      exclude.map {|i| i.strip}.reject {|i| i =~ /^#/ || i.empty?}
      # IE: ["/handlers", "/bundled*", "/vendor/jets]
    end

    # We clean out ignored files pretty aggressively. So provide
    # a way for users to keep files from being cleaned ou.
    def jetskeep
      defaults = %w[.bundle bundled pack handlers]
      path = "#{@project_root}/.jetskeep"
      return defaults unless File.exist?(path)

      keep = IO.readlines(path)
      keep = keep.map {|i| i.strip}.reject { |i| i =~ /^#/ || i.empty? }
      (defaults + keep).uniq
    end

    # folders to remove in the bundled folder regardless of the level of the folder
    def tidy_bundled
      puts "check #{@project_root}/bundled/**/*"
      Dir.glob("#{@project_root}/bundled/**/*").each do |path|
        next unless File.directory?(path)
        dir = File.basename(path)
        next unless default_excludes.include?(dir)
        puts "  rm -rf #{path}".colorize(:yellow) # uncomment to debug
        FileUtils.rm_rf(path)
      end
    end

    def default_excludes
      %w[.git tmp log spec cache]
    end
  end
end