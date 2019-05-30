# When upgrading jets, automatically rm -rf /tmp/jets/project in case the structure has changed.
module Jets::Builders
  class Purger
    def initialize
      @project_name = Jets.config.project_name
      @version_file = "/tmp/jets/#{@project_name}/jets_version.txt"
    end

    def purge
      if version_changed?
        last_version = @last_version || "unknown"
        puts "The jets version has changed enough since the last build to merit refreshing the build cache."
        puts "Current jets version: #{Jets::VERSION} Last built jets version: #{last_version}"
        puts "Removing /tmp/jets/#{@project_name} to start fresh."
        FileUtils.rm_rf("/tmp/jets/#{@project_name}")
      end
      write_version
    end

    # When jets changes versions major or minor version consider it a big enough can to purge the cache
    def version_changed?
      return true unless File.exist?(@version_file)

      @last_version = IO.read(@version_file).strip
      last_major, last_minor, _ = @last_version.split('.')
      current_major, current_minor, _ = Jets::VERSION.split('.')
      last_major != current_major || last_minor != current_minor
    end

    def write_version
      FileUtils.mkdir_p(File.dirname(@version_file))
      IO.write(@version_file, Jets::VERSION)
    end
  end
end