module Jets::Core::Config
  # Intentionally keep this class simple.
  # Frameworks should do the heavy lifting.
  class Project < Base
    attr_accessor(
      :autoload_paths,
      :ignore_paths,
      :base64_encode,
      :dotenv,
      :git,
      :ps,
      :scale,
      :tips
    )
    def initialize(*)
      @autoload_paths = Set.new(%w[
        app/events
        app/extensions
        shared/resources
        shared/extensions
      ])
      @ignore_paths = Set.new(%w[
        app/functions
        shared/functions
      ])
      # Jets does not implement the concept of eager_load_paths like Rails for simplicity.
      # Also Jets always does an eager load of app code that it manages above.
      # This is because shared/extensions and shared/resources needed to be defined
      # early to generate the CloudFormation templates.

      @dotenv = ActiveSupport::OrderedOptions.new
      @dotenv.ssm = ActiveSupport::OrderedOptions.new
      @dotenv.ssm.autoload = ActiveSupport::OrderedOptions.new
      @dotenv.ssm.autoload.default_skip = ["BASIC_AUTH_USERNAME", "BASIC_AUTH_PASSWORD", "BASIC_AUTH_CREDENTIALS"]
      @dotenv.ssm.autoload.enable = true # autoloads parameters by path IE: /demo/dev/
      @dotenv.ssm.autoload.skip = []
      @dotenv.ssm.convention_resolver = nil # proc receives ssm_leaf_name
      @dotenv.ssm.envs = ActiveSupport::OrderedOptions.new
      @dotenv.ssm.envs.fallback = "dev"
      @dotenv.ssm.envs.unique = ["dev", "prod"]
      @dotenv.ssm.long_env_helper = false   # for completeness
      @dotenv.ssm.long_env_name = false     # helps with Jets 5 legacy

      @base64_encode = true

      # Not yet documented because the config interface may change.
      @git = ActiveSupport::OrderedOptions.new
      @git.bin = "/usr/bin/git"
      @git.push = ActiveSupport::OrderedOptions.new
      @git.push.branch = ActiveSupport::OrderedOptions.new

      @ps = ActiveSupport::OrderedOptions.new
      @ps.format = "auto"
      @ps.summary = true

      @scale = ActiveSupport::OrderedOptions.new
      @scale.manual_changes = ActiveSupport::OrderedOptions.new
      @scale.manual_changes.warning = false
      @scale.manual_changes.retain = false

      @tips = ActiveSupport::OrderedOptions.new
      @tips.enable = true
      @tips.concurrency_change = true
      @tips.env_change = true
      @tips.faster_deploy = false
      @tips.remote_run = true
      @tips.ssm_change = true
    end

    attr_writer :name
    def name
      if ENV["JETS_PROJECT"] && !ENV["JETS_PROJECT"].blank?
        return ENV["JETS_PROJECT"]
      end

      # Too easy to call a method that requires the project name before Jets.boot.
      # Ran into this a few times.
      # IE: Ran into this with Jets API ping. That's no longer requires Jets.project.name
      # But will leave this here in case we miss Jets.boot in the future.
      Jets::Core::Booter.require_config(:project)
      return @name if @name

      project_name = jets_info_project_name
      unless project_name
        puts "ERROR: Jets project name not set".color(:red)
        abort <<~EOL
          Please set config.name in config/jets/project.rb or the JETS_PROJECT environment variable
          Example:

          config/jets/project.rb

              Jets.project.configure do
                config.name = "demo"
              end

          Or set the JETS_PROJECT environment variable:

              export JETS_PROJECT=demo
        EOL
      end
    end
    memoize :name

    def jets_info_project_name
      info = Jets::Core::Config::Info.instance
      info.project_name if info.respond_to?(:project_name)
    end

    def name_inferred?
      name # trigger memoization
      !!@name_inferred
    end

    def namespace
      [name, Jets.env, Jets.extra].compact.join("-").tr("_", "-")
    end

    def s3_bucket
      Jets::Cfn::Resource::S3::JetsBucket.name
    end

    def extension_paths
      @autoload_paths.select { |path| path.ends_with?("/extensions") }
    end

    # Useful for jets rails engine
    # Used to ignore all paths managed by Jets
    def all_load_paths
      @autoload_paths + @ignore_paths
    end
  end
end
