module Jets::Cfn
  class Bootstrap
    def initialize(options = {})
      @options = options.merge(bootstrap: true)
    end

    def run
      Builder::Parent::Genesis.new(@options).build
      success = Deploy.new(@options).sync # returns true if success
      abort("Bootstrap deploy failed") unless success
    end
  end
end
