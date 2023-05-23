module Jets::Cfn::Params::Api
  class Cors < Base
    # interface method
    def build
      resources = Resources.new(@options).params
      methods = Methods.new(@options).params
      @params = resources.merge(methods)
    end
  end
end
