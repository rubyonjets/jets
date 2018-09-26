module Jets::Commands
  class New < Sequence
    VALID_MODES = %w[html api job]
    argument :project_name

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with jets new help :(
    # If anyone knows how to fix this let me know.
    def self.cli_options
      [
        [:bootstrap, type: :boolean, default: true, desc: "Install bootstrap css"], # same option in WebpackerTemplate
        [:database, type: :boolean, default: true, desc: "Adds database"],
        [:force, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files."],
        [:git, type: :boolean, default: true, desc: "Git initialize the project"],
        [:mode, default: 'html', desc: "mode: #{VALID_MODES.join(',')}"],
        [:repo, desc: "GitHub repo to use. Format: user/repo"],
        [:webpacker, type: :boolean, default: true, desc: "Install webpacker"],
      ]
    end

    cli_options.each do |args|
      class_option(*args)
    end

    def set_api_mode
      # options is a frozen hash by Thor so cannot modify it.
      # Also had trouble unfreezing it with .dup. So using instance variables instead
      case options[:mode]
      when 'html'
        @webpacker = options[:webpacker]
        @bootstrap = options[:bootstrap]
      when 'api', 'job'
        @webpacker = false
        @bootstrap = false
      else
        puts "Invalid mode provided: #{@options[:mode].colorize(:red)}. Please pass in an valid mode: #{VALID_MODES.join(',').colorize(:green)}."
        exit 1
      end
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
      return unless @webpacker

      command = "jets webpacker:install"
      command += " FORCE=1" if options[:force]
      run(command)
    end

    # bootstrap is dependent on webpacker, options[:bootstrap] is used
    # in webpacker_install.
    def bootstrap_install
      return unless @bootstrap

      # Add jquery and popper plugin to handle Delete of CRUD
      jquery =<<-JS
const webpack = require('webpack')
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
JS
      after = "const { environment } = require('@rails/webpacker')\n"
      insert_into_file("config/webpack/environment.js", jquery, after: after)

      run("yarn add bootstrap@4.0.0-beta jquery popper.js")
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
      more_info = if options[:mode] == 'job'
        <<~EOL
          Learn more about jobs here: http://rubyonjets.com/docs/jobs/

          To deploy to AWS Lambda:
            jets deploy
        EOL
      else
        <<~EOL
          To start a server and test locally:
            jets server # localhost:8888 should have the Jets welcome page

          Scaffold example:
            jets generate scaffold Post title:string body:text published:boolean

          To deploy to AWS Lambda, edit your .env.development.remote and add a DATABASE_URL endpoint.
          Then run:

            jets deploy
        EOL
      end

      puts <<~EOL
        #{"="*64}
        Congrats 🎉 You have successfully created a Jets project.

        Cd into the project directory:
          cd #{project_name}

        #{more_info}
      EOL
    end
  end
end
