require 'recursive-open-struct'
require 'yaml'

# The Project default options.
# Overriden with config/project.yml
class Jets::Project
  class << self
    # Allows calling top level options with the dot notation
    # Jets::Project.project_name
    # Jets::Project.timeout
    # Jets::Project.level1_option.level2_option
    # Jets::Project.level1_option.level2_option.level3_option
    def method_missing(method_name)
      Jets::Project.new.options.send(method_name)
    end
  end

  # The options from the files get merged with the following precedence:
  #
  # current folder - The current folder’s config/application.yml values take the highest precedence.
  # user - The user’s ~/.jets/application.yml values take the second highest precedence.
  # default - The default settings bundled with the jets tool takes the lowest precedence.
  #
  # More info: http://rubyonjets.com/docs/settings/
  @options = nil
  def options
    return @options if @options

    project_settings = "#{Jets.root}/config/application.yml"
    project = File.exist?(project_settings) ? YAML.load_file(project_settings) : {}

    user_settings = "#{ENV['HOME']}/.jets/application.yml"
    user = File.exist?(user_settings) ? YAML.load_file(user_settings) : {}

    defaults_file = File.expand_path("../default/application.yml", __FILE__)
    defaults = YAML.load_file(defaults_file)

    options = defaults.deep_merge(user.deep_merge(project))
    # Even though default env can be configured in the config/settings.yml file.
    # The JETS_ENV environment variable can be set and takes higher precedence
    # over the settings file.
    options['env'] = ENV['JETS_ENV'] if ENV['JETS_ENV']

    @options = RecursiveOpenStruct.new(options)
  end
end
