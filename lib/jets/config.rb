require 'recursive-open-struct'
require 'yaml'

# The Config default settings.
# Overriden with config/project.yml
class Jets::Config
  class << self
    # Allows calling settings with the dot notation:
    # Jets.config.project_name
    # Jets.config.timeout
    # Jets.config.level1_option.level2_option
    # Jets.config.level1_option.level2_option.level3_option
    def method_missing(method_name)
      settings = Jets.config.new.settings
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
  # More info: http://rubyonjets.com/docs/settings/
  @@settings = nil
  def settings
    return @@settings if @@settings

    project = load_yaml("#{Jets.root}/config/application.yml")

    user = load_yaml("#{ENV['HOME']}/.jets/application.yml")

    defaults_file = File.expand_path("../default/application.yml", __FILE__)
    defaults = load_yaml(defaults_file)

    # Merge it all together
    settings = defaults.deep_merge(user.deep_merge(project))

    settings['env'] = ENV['JETS_ENV'] || 'development'
    # env_instance can be set in the settings file but JETS_ENV cannot
    settings['env_instance'] = ENV['JETS_ENV_INSTANCE'] if ENV['JETS_ENV_INSTANCE']

    # Extra helpful aliases
    set_aliases!(settings)

    @@settings = RecursiveOpenStruct.new(settings)
  end

  # Also renders ERB to enable ENV['XXX'] variables use in application.yml.
  # Should use Jets.config variables because that'll cause an infinite loop.
  def load_yaml(path)
    File.exist?(path) ? YAML.load(Jets::Erb.result(path)) : {}
  end

  # Use the shorter name in stack names, but use the full name when it
  # comes to checking for the env.
  #
  #   Jets.env == 'development'
  #   Jets.config.project_namespace == 'proj-dev'
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
    # table_namespace does not have the env_instance.  Think it's more common to want this case.
    s['table_namespace'] = [s['project_name'], s['short_env']].compact.join('-')
  end

end
