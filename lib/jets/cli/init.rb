class Jets::CLI
  class Init < Jets::CLI::Group::Base
    include Jets::Util::Sure

    def self.cli_options
      [
        [:env, type: :boolean, desc: "Generate config/jets/env/.env example file"],
        [:force, aliases: :f, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        [:yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"]
      ]
    end
    cli_options.each { |args| class_option(*args) }

    source_root "#{__dir__}/init/templates"

    private

    def sure_message
      detected_message = "Detected #{framework.titleize} framework.\n" if framework
      <<~EOL
        #{detected_message}This will initialize the project for Jets.

        It will make changes to your project source code.

        Please make sure you have backed up and committed your changes first.
      EOL
    end

    def configure_rails
      # config/environments/production.rb adjustments
      # Comment out public_file_server.enabled on new Rails 7.0 apps
      #    config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
      comment_out_line("config.public_file_server.enabled = ENV", env: "production")
      config_environment("config.public_file_server.enabled = false\n\n", env: "production")
      # Comment out config.asset_host = "http://assets.example.com" on new Rails 7.0 apps
      #    config.asset_host = "http://assets.example.com"
      comment_out_line('config.asset_host = "', env: "production")
      asset_host = <<~EOL

        # Assets https://docs.rubyonjets.com/docs/assets/cloudfront/
        config.asset_host = ENV["JETS_ASSET_HOST"] unless ENV["JETS_ASSET_HOST"].blank?
      EOL
      config_environment(asset_host, env: "production")

      jets_job = <<~EOL
        # Jobs https://docs.rubyonjets.com/docs/jobs/enable/
        # config.active_job.queue_adapter = :jets_job
      EOL
      config_environment(jets_job, env: "production")
    end

    def configure_hanami
      after = "  class App < Hanami::App\n"
      data = <<~EOL
        # https://guides.hanamirb.org/v2.1/assets/using-a-cdn/
        # https://docs.rubyonjets.com/docs/assets/cloudfront/
        config.assets.base_url = ENV["JETS_ASSET_HOST"] if ENV["JETS_ASSET_HOST"]
      EOL
      inject_into_file "config/app.rb", optimize_indentation(data, 4), after: after, verbose: true
    end

    public

    def are_you_sure?
      return if options[:yes] || options[:force]
      sure?(sure_message)
    end

    def env_example
      # need to create .env for RAILS_ENV=production
      create_env = @options[:env].nil? ? framework == "rails" : @options[:env]
      if create_env
        template "env/.env.tt", "config/jets/env/.env"
      end
    end

    def config_jets
      directory "config/jets", "config/jets"
    end

    def configure_environment
      case framework
      when "rails"
        configure_rails
      when "hanami"
        configure_hanami
      end
    end
  end
end
