module Jets::Lambda
  class RegisteredFunction
    attr_reader :meth, :properties
    def initialize(meth, properties={})
      @meth = meth
      @properties = properties
    end
  end
end
