require 'recursive-open-struct'
require 'yaml'

# The Config default settings.
# Overriden with config/project.yml
class Jets::Config
  class << self
    # Allows calling top level settings with the dot notation
    # Jets::Config.project_name
    # Jets::Config.timeout
    # Jets::Config.level1_option.level2_option
    # Jets::Config.level1_option.level2_option.level3_option
    def method_missing(method_name)
      Jets::Config.new.settings.send(method_name)
    end
  end

  # The settings from the files get merged with the following precedence:
  #
  # current folder - The current folder’s config/application.yml values take the highest precedence.
  # user - The user’s ~/.jets/application.yml values take the second highest precedence.
  # default - The default settings bundled with the jets tool takes the lowest precedence.
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

    settings = defaults.deep_merge(user.deep_merge(project))
    # Even though default env can be configured in the config/settings.yml file.
    # The JETS_ENV environment variable can be set and takes higher precedence
    # over the settings file.
    settings['env'] = ENV['JETS_ENV'] if ENV['JETS_ENV']

    @@settings = RecursiveOpenStruct.new(settings)
  end
end
