module Jets::Code::Copy
  class GitCopy < Base
    # interface method
    def create_temp_zip
      copy_to_code_temp # interface method

      # We leverage git archive for gitignore settings.
      Dir.chdir("#{build_root}/stage/code-temp") do
        if git_info.params[:git_dirty]
          quiet_sh "git add ."
          gitconfig
          quiet_sh "git commit -m 'add working tree files' > /dev/null || true"
        end
        quiet_sh "git archive -o #{build_root}/stage/code-temp.zip HEAD"
      end
    end

    # Copy project to stage/code-temp to use git add and archive
    # without affecting up the current git repo.
    # interface method. overriden by GitRsync
    def copy_to_code_temp
      FileUtils.mkdir_p("#{build_root}/stage")
      FileUtils.cp_r(Jets.root, "#{build_root}/stage/code-temp")
    end
  end
end
