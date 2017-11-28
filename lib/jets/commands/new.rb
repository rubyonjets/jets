module Jets::Commands
  class New < Sequence
    argument :project_name
    class_option :repo, default: "tongueroo/starter", desc: "Starter repo to use."

    def copy_project
      puts "Creating new project called #{project_name}."
      directory ".", project_name
    end

    def git_init
      git_installed = system("type git > /dev/null")
      return unless git_installed

      system("cd #{project_name} && git init")
      system("cd #{project_name} && git add .")
      system("cd #{project_name} && git commit -m 'first commit'")
    end

    def bundle_install
      # Bundler.with_clean_env do
      #   system("cd #{project_name} && BUNDLE_IGNORE_CONFIG=1 bundle install")
      # end
    end

    def user_message
      puts "=" * 64
      puts "Congrats 🎉 You have successfully created a Jets project."
      puts "To deploy the project to AWS Lambda:"
      puts "  cd #{project_name}".colorize(:green)
      puts "  jets deploy".colorize(:green)
    end
  end
end
