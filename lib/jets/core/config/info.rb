require "singleton"

module Jets::Core::Config
  class Info
    extend Memoist
    include Singleton

    def data
      data = File.exist?(path) ? YAML.load_file(path) : {}
      ActiveSupport::HashWithIndifferentAccess.new(data)
    end
    memoize :data

    def method_missing(name, *args)
      data.key?(name.to_sym) ? data[name.to_sym] : super
    end

    def respond_to_missing?(name, include_private = false)
      data.key?(name.to_sym) || super
    end

    # Do not use absolute path.  This is because the path is written to the stage/code area
    def path
      "config/jets/info.yml"
    end
  end
end
