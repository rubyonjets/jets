module Jets::Router::Resources
  class Base
    def initialize(name, options)
      @name, @options = name, options
    end
  end
end
