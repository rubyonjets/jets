require "yaml"
require "active_support"
require "active_support/core_ext/hash"

module Jets::Git
  class Saved
    extend Memoist

    # gitinfo.yml contains original git info from the project
    def params
      return {} unless File.exist?(".jets/gitinfo.yml")
      data = YAML.load_file(".jets/gitinfo.yml")
      ActiveSupport::HashWithIndifferentAccess.new(data)
    end
  end
end
