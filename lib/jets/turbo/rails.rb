class Jets::Turbo
  class Rails
    attr_reader :build_area
    def initialize
      @build_area = "/tmp/jets"
      @project_folder = "turbo-wrapper-project"
    end

    def setup
      afterburners_message
      check_old_dot_jets_app_folder!
      clean
      override_env_vars
      wrapper_jets_project
      copy_rack_project
      reconfigure_database_yml
      apply_dot_jets_project
      set_project_name
    end

    def afterburners_message
      command = ARGV.first
      if command == "deploy"
        puts "=> Rails app detected: Enabling Jets Afterburner to deploy to AWS Lambda.".color(:green)
      else
        puts "=> Rails app detected: Enabling Jets Afterburner.".color(:green)
      end
    end

    def check_old_dot_jets_app_folder!
      return unless File.exist?(".jets/app")

      puts <<~EOL.color(:red)
        ERROR: .jets/app folder exists. Starting in version jets v1.9.23 this folder should be renamed to .jets/project.
        Please run:

            mv .jets/app .jets/project

      EOL
      exit 1
    end

    # Hack env vars to support Jets Turbo mode
    def override_env_vars
      ENV['BUNDLE_GEMFILE'] = "#{build_area}/#{@project_folder}/Gemfile"
      ENV['JETS_ROOT'] = "#{build_area}/#{@project_folder}"
      # Jets.root /home/ec2-user/environment/jet-pack/lib/turbo-wrapper-project
    end

    def wrapper_jets_project
      jets_project = File.expand_path("project", File.dirname(__FILE__))
      project_path = "#{build_area}/#{@project_folder}"

      FileUtils.mkdir_p(build_area)
      FileUtils.rm_rf(project_path)
      Jets::Util.cp_r(jets_project, project_path)

      IO.write("#{project_path}/date.txt", Time.now) # update date.txt file to ensure Lambda function code changes and updates
    end

    def set_project_name
      path = "#{build_area}/#{@project_folder}/config/application.rb"
      lines = IO.readlines(path)
      lines.map! do |l|
        if l.include?('config.project_name = "project"')
          %Q|  config.project_name = "#{project_name}"\n|
        else
          l
        end
      end
      IO.write(path, lines.join(''))
    end

    def project_name
      path = "#{build_area}/#{@project_folder}/project_name"
      name = if File.exist?(path)
                IO.read(path).strip # project_name
              else
                File.basename(Dir.pwd)
              end
      name.gsub('_','-') # project_name
    end

    # Anything in rails_project/.jets/project will override the generic wrapper project.
    #
    #   rails_project/.jets/project/.env => jets_project/.env
    #   rails_project/.jets/project/config/database.yml => jets_project/config/database.yml
    #
    # This useful for DATABASE_URL and other env vars.
    def apply_dot_jets_project
      # Dir.pwd: /home/ec2-user/environment/demo-rails
      # Jets.root: /tmp/jets/turbo-wrapper-project/
      dot_jets_app = "#{Dir.pwd}/.jets/project"

      return unless File.exist?(dot_jets_app)
      # Trailing slashes are required for both folders. Jets.root already has the trailing slash
      sh "rsync -a --links #{dot_jets_app}/ #{Jets.root}", quiet: true
    end

    def reconfigure_database_yml
      DatabaseYaml.new.reconfigure
    end

    def copy_rack_project
      dest = "#{build_area}/#{@project_folder}/rack"
      # puts "cp -r #{Dir.pwd} #{dest}" # uncomment to see and debug
      Jets::Util.cp_r(Dir.pwd, dest)
    end

    # TODO: remove duplication, copied from jets/commands/import/base.rb
    # And modified it slightly
    def bundle_install
      Bundler.with_unbundled_env do
        sh "cd #{build_area}/#{@project_folder}/rack && bundle install"
      end
    end

    def sh(command, quiet: false)
      puts "=> #{command}" unless quiet
      system command
    end

    def clean
      FileUtils.rm_rf("#{build_area}/#{@project_folder}/rack")
    end
  end
end
