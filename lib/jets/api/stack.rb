module Jets::Api
  class Stack < Base
    class << self
      def list(params = {})
        api.get("/stacks", params)
      end

      def retrieve(id, params = {})
        id = Jets.project.namespace if id == :current
        api.get("/stacks/#{id}", params)
      end
    end
  end
end
