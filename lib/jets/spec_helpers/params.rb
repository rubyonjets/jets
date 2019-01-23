module Jets
  module SpecHelpers
    class Params
      attr_accessor :path_params, :body_params
      def initialize(path_params={}, body_params={})
        @path_params, @body_params = path_params, body_params
      end
    end
  end
end
