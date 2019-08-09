require 'shellwords'

class Jets::Util
  class << self
    # Make sure that the result is a text.
    def normalize_result(result)
      JSON.dump(result)
    end

    def cp_r(src, dest)
      # Fix for https://github.com/tongueroo/jets/issues/122
      #
      # Using FileUtils.cp_r doesnt work if there are special files like socket files in the src dir.
      # Instead of using this hack https://bugs.ruby-lang.org/issues/10104
      # Using rsync to perform the copy.
      src.chop! if src.ends_with?('/')
      dest.chop! if dest.ends_with?('/')
      check_rsync_installed!
      sh "rsync -a --links --no-specials --no-devices #{Shellwords.escape(src)}/ #{Shellwords.escape(dest)}/", quiet: true
    end

    @@rsync_installed = false
    def check_rsync_installed!
      return if @@rsync_installed # only check once
      if system "type rsync > /dev/null 2>&1"
        @@rsync_installed = true
      else
        raise Jets::Error.new("Rsync is required. Rsync does not seem to be installed.")
      end
    end

    def sh(command, quiet: false)
      puts "=> #{command}" unless quiet
      system(command)
      success = $?.success?
      raise Jets::Error.new("Command failed: #{command}") unless success
      success
    end
  end
end
