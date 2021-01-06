module Jets::Commands
  class New < Sequence
    VALID_MODES = %w[html api job]
    argument :project_folder

    # Ugly, but when the class_option is only defined in the Thor::Group class
    # it doesnt show up with jets new help :(
    # If anyone knows how to fix this let me know.
    def self.cli_options
      [
        [:bootstrap, type: :boolean, default: true, desc: "Install bootstrap css"], # same option in WebpackerTemplate
        [:database, type: :string, default: 'mysql', desc: "Preconfigure database (options: mysql/postgresql)"],
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

    def set_initial_variables
      @project_name = project_folder == '.' ? File.basename(Dir.pwd) : project_folder
      @database_name = @project_name.gsub('-','_')

      # options is a frozen hash by Thor so cannot modify it.
      # Also had trouble unfreezing it with .dup. So using instance variables instead
      case options[:mode]
      when 'html'
        @bootstrap = options[:bootstrap]
        @database = options[:database]
        @webpacker = options[:webpacker]
      when 'api'
        @bootstrap = false
        @database = options[:database]
        @webpacker = false
      when 'job'
        @bootstrap = false
        @database = false
        @webpacker = false
      else
        puts "Invalid mode provided: #{@options[:mode].color(:red)}. Please pass in an valid mode: #{VALID_MODES.join(',').color(:green)}."
        exit 1
      end
    end

    def create_project
      options[:repo] ? clone_project : copy_project

      destination_root = "#{Dir.pwd}/#{project_folder}"
      self.destination_root = destination_root
      FileUtils.cd("#{Dir.pwd}/#{project_folder}")
    end

    def make_bin_executable
      return unless File.exist?("bin")
      chmod "bin", 0755 & ~File.umask, verbose: false
    end

    def bundle_install
      Bundler.with_unbundled_env do
        system("BUNDLE_IGNORE_CONFIG=1 bundle install")
      end
    end

    def webpacker_install
      return unless @webpacker
      unless yarn_installed?
        puts "Yarn is not installed or has not been detected. Please double check that yarn has been installed.".color(:red)
        puts <<~EOL
          To check:

              which yarn

          If it is not installed, you can usually install it with:

              npm install -g yarn

          Refer to the install docs for more info: http://rubyonjets.com/docs/install/
        EOL
        exit 1
      end

      command = "bundle exec jets webpacker:install"
      command += " FORCE=1" if options[:force]
      run(command)
    end

    def update_package_json
      path = "package.json"
      return unless File.exist?(path)
      data = JSON.load(IO.read(path))
      data["private"] = true
      IO.write(path, JSON.pretty_generate(data))
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

      run("yarn add bootstrap jquery popper.js postcss-cssnext")
    end

    def git_init
      return if !options[:git]
      return unless git_installed?
      return if File.exist?(".git") # this is a clone repo
      return unless git_credentials_set?

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
            jets generate scaffold post title:string body:text published:boolean
            jets db:create db:migrate

          To deploy to AWS Lambda, edit your .env.development.remote and add a DATABASE_URL endpoint.
          Then run:

            jets deploy
        EOL
      end

      puts <<~EOL
        #{"="*64}
        Congrats 🎉 You have successfully created a Jets project.

        Cd into the project directory:
          cd #{project_folder}

        #{more_info}
      EOL
    end
  end
end
