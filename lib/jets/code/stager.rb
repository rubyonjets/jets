require "active_support"
require "active_support/number_helper"

class Jets::Code
  class Stager
    extend Memoist
    include Jets::Util::Git
    include Jets::Util::Logging
    include Jets::Util::Sh

    delegate :build_root, to: Jets
    delegate :config, to: "Jets.bootstrap.config"

    def build
      clean
      warn_large_codebase
      stage_code # interface method
      save_deploy_user
      save_project_name
      save_ruby_version
      touch_deployed_at
    end

    # interface method: overridden by Dummy
    def stage_code
      log.debug "Copying project to #{build_root}/stage/code"
      log.debug "Copy strategy: #{copy_strategy}"
      copy_strategy.run
    end

    def copy_strategy
      strategy = config.code.copy.strategy.to_s
      if strategy == "auto"
        auto_strategy
      else # whatever user overrides it to
        class_name = strategy.camelize
        Copy.const_get(class_name) # Copy::GitInline
      end
    end
    memoize :copy_strategy

    def auto_strategy
      if File.exist?("#{Jets.root}/.git") && rsync_installed?
        Copy::Rsync
      elsif git? # .git folder exists and git command available
        Copy::GitCopy
      else # full copy
        Copy::Full # FileUtils.cp_r(Jets.root, "#{build_root}/stage/code")
      end
    end

    @@rsync_installed = nil # only check once
    def rsync_installed?
      return @@rsync_installed unless @@rsync_installed.nil?
      @@rsync_installed = system "type rsync > /dev/null 2>&1"
    end

    def save_deploy_user
      User.new.save
    end

    # Save the project_name in .jets/info.yml if inferred
    # Better to write the file here instead of within the Jets::Core::Config::Info class.
    # Because Info assumes Jets.root is Dir.pwd
    # We need to ensure it's written to stage/code not the current project root.
    def save_project_name
      return unless Jets.project.name_inferred?

      jets_info = Jets::Core::Config::Info.instance
      data = jets_info.data.merge(project_name: Jets.project.name)
      dest = "#{build_root}/stage/code/#{jets_info.path}"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, data.to_h.to_yaml)
    end

    # Save by moving .ruby-version to .jets/ruby-version
    # So it does not affect codebuild ruby version.
    def save_ruby_version
      Dir.chdir("#{build_root}/stage/code") do
        move_ruby_version(".ruby-version")
        move_ruby_version(".tool-versions") # future proofing for asdf
      end
    end

    def move_ruby_version(filename = ".ruby-version")
      if File.exist?(filename)
        FileUtils.mkdir_p(".jets")
        FileUtils.mv(filename, ".jets/#{filename}")
      end
    end

    def touch_deployed_at
      dest = "#{build_root}/stage/code/.jets/deployed_at"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, Time.now.utc.to_s)
    end

    def clean
      FileUtils.rm_rf("#{build_root}/stage/code")
      FileUtils.rm_rf("#{build_root}/stage/code-temp")
      FileUtils.mkdir_p(File.dirname("#{build_root}/stage/code"))
    end

    def warn_large_codebase
      return unless Jets.bootstrap.code.copy.warn_large
      return unless system("type du > /dev/null 2>&1")

      # Use -k for cross-platform compatibility, multiply by 1024 to get bytes
      # Works for both macOS and Linux
      bytes = `du -ks #{Jets.root}`.split("\t").first.to_i * 1024

      if bytes > 1024 * 1024 * 1024 # 1GB
        size = ActiveSupport::NumberHelper.number_to_human_size(bytes)
        log.info <<~EOL
          WARNING: Large codebase detected: #{size}
          Will take some time to zip and upload. Please be patient.
          You can turn off this warning with

          config/jets/bootstrap.rb

              Jets.bootstrap.configure do
                config.code.copy.warn_large = false
              end
        EOL
      end
    end
  end
end
