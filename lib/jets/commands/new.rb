module Jets::Commands
  class New < Sequence
    argument :project_name

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with jets new help :(
    # If anyone knows how to fix this let me know.
    def self.cli_options
      [
        [:repo, desc: "GitHub repo to use. Format: user/repo"],
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:webpacker, type: :boolean, default: true, desc: "Install webpacker"],
        [:bootstrap, type: :boolean, default: true, desc: "Install bootstrap"], # same option in WebpackerTemplate
        [:git, type: :boolean, default: true, desc: "Git initialize the project"],
      ]
    end

    cli_options.each do |args|
      class_option *args
    end

    def create_project
      options[:repo] ? clone_project : copy_project

      destination_root = "#{Dir.pwd}/#{project_name}"
      self.destination_root = destination_root
      FileUtils.cd("#{Dir.pwd}/#{project_name}")
    end

    def make_bin_executable
      chmod "bin", 0755 & ~File.umask, verbose: false
    end

    def bundle_install
      Bundler.with_clean_env do
        system("BUNDLE_IGNORE_CONFIG=1 bundle install")
      end
    end

    def webpacker_install
      return unless options[:webpacker]

      command = "jets webpacker:install"
      command += " FORCE=1" if options[:force]
      run(command)
    end

    # bootstrap is dependent on webpacker, options[:bootstrap] is used
    # in webpacker_install.
    def bootstrap_install
      puts "bootstrap_install options: #{options.inspect}"
      return unless options[:bootstrap]

      jquery =<<-JS
const webpack = require('webpack')
environment.plugins.set('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
JS
      after = "const { environment } = require('@rails/webpacker')\n"
      insert_into_file("config/webpack/environment.js", jquery, after: after)
    end

    def git_init
      return if !options[:git]
      return unless git_installed?
      return if File.exist?(".git") # this is a clone repo

      run("git init")
      run("git add .")
      run("git commit -m 'first commit'")
    end

    def user_message
      puts "=" * 64
      puts "Congrats 🎉 You have successfully created a Jets project.\n\n"
      puts "To test locally:"
      puts "  cd #{project_name}".colorize(:green)
      puts "  jets server".colorize(:green)
      puts ""
      puts "To deploy to AWS Lambda:"
      puts "  jets deploy".colorize(:green)
      puts ""
    end
  end
end
