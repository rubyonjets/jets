class Jets::Build
  class Route
    def initialize(options)
      @options = options
    end

    def path
      @options[:path]
    end

    def method
      @options[:method].to_s.upcase
    end

    # IE: posts#create
    def to
      @options[:to]
    end

    # PostsController
    def controller_name
      to.sub(/#.*/,'').camelize + "Controller"
    end
  end
end
