require 'recursive-open-struct'
require 'yaml'

# The Config default settings.
# Overriden with config/project.yml
class Jets::Config
  class << self
    # Allows calling settings with the dot notation:
    # Jets::Config.project_name
    # Jets::Config.timeout
    # Jets::Config.level1_option.level2_option
    # Jets::Config.level1_option.level2_option.level3_option
    def method_missing(method_name)
      settings = Jets::Config.new.settings
      if settings.to_h.has_key?(method_name)
        settings[method_name]
      else
        super
      end
    end
  end

  # The settings from the files get merged with the following precedence:
  #
  # current folder - The projects config/application.yml values take the highest precedence.
  # user - The user’s ~/.jets/application.yml values take the second highest precedence.
  # default - The default settings bundled with the jets tool takes the lowest precedence.
  #
  # Even though default env can be configured in the config/settings.yml file.
  # The JETS_ENV environment variable can be set and takes highest precedence
  # over the settings file.
  #
  # More info: http://rubyonjets.com/docs/settings/
  @@settings = nil
  def settings
    return @@settings if @@settings

    project_settings = "#{Jets.root}/config/application.yml"
    project = File.exist?(project_settings) ? YAML.load_file(project_settings) : {}

    user_settings = "#{ENV['HOME']}/.jets/application.yml"
    user = File.exist?(user_settings) ? YAML.load_file(user_settings) : {}

    defaults_file = File.expand_path("../default/application.yml", __FILE__)
    defaults = YAML.load_file(defaults_file)

    # Merge it all together
    settings = defaults.deep_merge(user.deep_merge(project))

    # JETS_ENV and JETS_ENV_INSTANCE takes highest precedence over files
    settings['env'] = ENV['JETS_ENV'] if ENV['JETS_ENV']
    settings['env_instance'] = ENV['JETS_ENV_INSTANCE'] if ENV['JETS_ENV_INSTANCE']
    # Extra helpful aliases
    set_aliases!(settings)

    @@settings = RecursiveOpenStruct.new(settings)
  end

  # Use the shorter name in stack names, but use the full name when it
  # comes to checking for the env.
  #
  #   Jets.env == 'development'
  #   Jets::Config.project_namespace == 'proj-dev'
  ENV_MAP = {
    development: 'dev',
    production: 'prod',
    staging: 'stag',
  }
  def set_aliases!(s)
    # IE: With env_instance: project-dev-1
    #     Without env_instance: project-dev
    short_env = ENV_MAP[s['env'].to_sym] || s['env']
    s['short_env'] = short_env
    s['project_namespace'] = [s['project_name'], s['short_env'], s['env_instance']].compact.join('-')
  end

end
