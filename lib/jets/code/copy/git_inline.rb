module Jets::Code::Copy
  class GitInline < Base
    def create_temp_zip
      # Git add and commit to current repo. Affects the working dir but faster.
      if git_info.params[:git_dirty]
        quiet_sh "git add ."
        gitconfig
        quiet_sh "git commit -m 'commit for deploy' > /dev/null || true"
      end
      quiet_sh "git archive -o #{build_root}/stage/code-temp.zip HEAD"
    end
  end
end
