module Jets::Resource
  module Replacer
    autoload :Base, 'jets/resource/replacer/base'
    autoload :ConfigRule, 'jets/resource/replacer/config_rule'
    # TODO: handle autoloading for plugins
  end
end
