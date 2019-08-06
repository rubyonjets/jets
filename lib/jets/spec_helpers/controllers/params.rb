module Jets::SpecHelpers::Controllers
  class Params
    attr_accessor :path_params, :body_params, :query_params
    def initialize(path_params={}, body_params={}, query_params={})
      @path_params, @body_params, @query_params = path_params, body_params, query_params
    end
  end
end
