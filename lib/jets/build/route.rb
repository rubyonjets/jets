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

    # for CloudFormation
    def logical_id
      "ApiMethod#{controller_method}"
    end

    def controller_method
      to.gsub('/','_').sub('#','_').camelize
    end

    def controller_name
      to.sub(/#.*/,'').camelize + "Controller"
    end
  end
end