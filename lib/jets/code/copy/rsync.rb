module Jets::Code::Copy
  class Rsync < Base
    # interface method
    def create_temp_zip
      FileUtils.mkdir_p("#{build_root}/stage/code-temp")
      excludes = " --exclude .git"
      excludes << " --exclude-from=#{Jets.root}/.gitignore" if File.exist?("#{Jets.root}/.gitignore")
      quiet_sh "rsync -aq#{excludes} #{Jets.root}/ #{build_root}/stage/code-temp"
      # Create zip file
      check_zip_installed!
      quiet_sh "cd #{build_root}/stage/code-temp && zip -q -r #{build_root}/stage/code-temp.zip ."
    end

    def check_zip_installed!
      return if system("type zip > /dev/null 2>&1")
      abort "ERROR: zip command is required. Please install zip command."
    end
  end
end
