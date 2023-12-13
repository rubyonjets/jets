require "fileutils"
require "gems"

module Jets::Thor
  class VersionCheck
    def check!
      return unless check_needed?

      remote_version = Gems.info("jets")["version"]
      local_version = Gem.loaded_specs["jets"].version

      return if remote_version.nil?

      if Gem::Version.new(remote_version) > Gem::Version.new(local_version)
        puts <<~EOL
          jets has a newer version available.

          installed version: #{local_version}
          latest version:    #{remote_version}

          Please update jets
        EOL
      end

      save_last_checked_time
    end

    def check_needed?
      check_interval = 24 * 60 * 60  # 24 hours in seconds
      Time.now - last_checked_time >= check_interval
    end

    def last_checked_time
      last_time = File.exist?(last_check_file) ? File.read(last_check_file) : "1970-01-01 00:00:00 UTC"
      Time.parse(last_time)
    end

    def save_last_checked_time
      FileUtils.mkdir_p(File.dirname(last_check_file))
      File.write(last_check_file, Time.now)
    end

    def last_check_file
      # Do not define last_check_file as a LAST_CHECK_FILE constant
      # On AWS lambda, Jets eager load errors since ENV["HOME"] is nil
      # Note: Added an extra safeguard in case ENV["HOME"] is nil
      home = ENV["HOME"] || "/root"
      File.join(home, ".jets/tmp/last-checked.txt")
    end
  end
end
