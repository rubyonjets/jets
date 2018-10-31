require "gems"

# Usage:
#
#   Jets::Gems::Extract::Gem.new("pg-0.21.0",
#     downloads_root: cache_area, # defaults to /tmp/lambdagem
#     dest: cache_area, # defaults to . (project_root)
#   ).run
#
module Jets::Gems::Extract
  class Gem < Base
    VERSION_PATTERN = /-(\d+\.\d+\.\d+.*)/

    def run
      say "Looking for #{full_gem_name} gem in: #{@options[:source_url]}"
      clean_downloads(:gems) if @options[:clean]
      tarball_path = download_gem
      remove_current_gem
      unpack_tarball(tarball_path)
      say("Gem #{full_gem_name} unpacked at #{project_root}", :debug)
    end

    # ensure that we always have the full gem name
    def full_gem_name
      return @full_gem_name if @full_gem_name

      if @name.match(VERSION_PATTERN)
        @full_gem_name = @name
        return @full_gem_name
      end

      # name doesnt have a version yet, so grab the latest version and add it
      version = Gems.versions(@name).first
      @full_gem_name = "#{@name}-#{version["number"]}"
    end

    def gem_name
      full_gem_name.gsub(VERSION_PATTERN,'') # folder: byebug
    end

    # Downloads and extracts the linux gem into the proper directory.
    # Extracts to: . (current directory)
    #
    # It produces a `bundled` folder.
    # The folder contains the re-produced directory structure. Example with
    # the gem: byebug-9.1.0
    #
    #   bundled/gems/ruby/2.5.0/extensions/x86_64-darwin-16/2.5.0-static/byebug-9.1.0
    #
    def download_gem
      # download - also move to /tmp/jets/demo/compiled_gems folder
      url = gem_url
      tarball_dest = download_file(url, download_path(File.basename(url)))
      unless tarball_dest
        message = "Url: #{url} not found"
        if @options[:exit_on_error]
          say message
          exit
        else
          raise NotFound.new(message)
        end
      end
      say "Tarball downloaded to: #{tarball_dest}"
      tarball_dest
    end

    def download_path(filename)
      "#{@downloads_root}/downloads/gems/#{filename}"
    end

    # Finds any currently install gems that matched with the gem name and version
    # and remove them first.
    # We clean up the current install gems first in case it was previously installed
    # and has different *.so files that can be accidentally required.  This
    # happened with the pg gem.
    def remove_current_gem
      say "Removing current #{full_gem_name} gem installation:"
      gem_dirs = Dir.glob("#{project_root}/**/*").select do |path|
                  File.directory?(path) &&
                  path =~ %r{bundled/gems} &&
                  File.basename(path) == full_gem_name
                end
      gem_dirs.each do |dir|
        say "  rm -rf #{dir}"
        FileUtils.rm_rf(dir)
      end
    end

    # full_gem_name: byebug-9.1.0
    def gem_url
      "#{source_url}/gems/#{ruby_version_folder}/#{gem_name}/#{full_gem_name}-x86_64-linux.tgz"
    end

    def ruby_version_folder
      Jets::Gems.ruby_version_folder
    end
  end
end
