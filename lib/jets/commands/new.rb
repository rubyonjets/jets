module Jets::Commands
  class New < Sequence
    argument :project_name

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with jets new help :(
    # If anyone knows how to fix this let me know.
    def self.cli_options
      [
        [:repo, desc: "Starter repo to use. Format: user/repo"],
        [:force, desc: "Bypass overwrite are you sure prompt for existing files."],
      ]
    end

    cli_options.each do |args|
      class_option *args
    end

    def create_project
      options[:repo] ? clone_project : copy_project
    end

    def git_init
      return unless git_installed?
      return if File.exist?("#{project_name}/.git") # this is a clone repo

      run("cd #{project_name} && git init")
      run("cd #{project_name} && git add .")
      run("cd #{project_name} && git commit -m 'first commit'")
    end

    def bundle_install
      Bundler.with_clean_env do
        system("cd #{project_name} && BUNDLE_IGNORE_CONFIG=1 bundle install")
      end
    end

    def webpacker_install
      # Always force webpacker:install. Going to overwrite later anyway as part
      # of WebpackerTemplate#reapply_templates.
      run("cd #{project_name} && jets webpacker:install")
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
