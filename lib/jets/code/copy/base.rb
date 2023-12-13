module Jets::Code::Copy
  class Base
    extend Memoist
    include Jets::Util::Git
    include Jets::Util::Logging
    include Jets::Util::Sh

    delegate :build_root, to: Jets
    delegate :config, to: "Jets.bootstrap.config"

    def self.run
      new.run
    end

    def run
      create_temp_zip # interface method
      extract_code # Now have a working area: stage/code
      remove_temp_files
      always_keep
      always_remove
      save_gitinfo
      "#{build_root}/stage/code"
    end

    # Extract code-temp.zip immediately
    def extract_code
      quiet_sh "unzip -q #{build_root}/stage/code-temp.zip -d #{build_root}/stage/code"
    end

    # Remove code-temp files. Not needed anymore.
    def remove_temp_files
      FileUtils.rm_f "#{build_root}/stage/code-temp.zip"
      FileUtils.rm_rf "#{build_root}/stage/code-temp"
    end

    def save_gitinfo
      dest = "#{build_root}/stage/code/.jets/gitinfo.yml"
      FileUtils.mkdir_p(File.dirname(dest))
      if File.exist?(".jets/gitinfo.yml")
        # already copied over
        FileUtils.cp(".jets/gitinfo.yml", dest)
      else
        IO.write(dest, git_info.params.deep_stringify_keys.to_yaml)
      end
    end

    def git_info
      Jets::Git::Info.new
    end
    memoize :git_info

    # Ensure gitconfig to avoid the Author identity unknown git warning.
    def gitconfig
      home = ENV["HOME"] || "/root"
      git_user = capture "git config user.name || true"
      return unless git_user.blank?

      IO.write("#{home}/.gitconfig", <<~EOL)
        [user]
          name = Nobody
          email = "nobody@email.com"
      EOL
    end

    # Copy always_keep files and folders like .deploy for remote runner
    # regardless of .gitignore. Allows user to use .deploy/.env files for remote runner
    # And have a .gitignore for .env at the project root level.
    def always_keep
      config.code.copy.always_keep.each do |path|
        next unless File.exist?(path)
        # Remove in case not gitignore. IE: avoid creating .deploy/.deploy
        FileUtils.rm_rf("#{build_root}/stage/code/#{path}")
        FileUtils.mkdir_p("#{build_root}/stage/code")
        FileUtils.cp_r(path, "#{build_root}/stage/code/#{path}")
      end
    end

    def always_remove
      config.code.copy.always_remove.each do |path|
        FileUtils.rm_rf("#{build_root}/stage/code/#{path}")
      end
    end
  end
end
