module Jets::Api
  class Release < Base
    class << self
      def list(params = {})
        api.get("/releases", params)
      end

      def retrieve(id, params = {})
        api.get("/releases/#{id}", params)
      end

      def create(params = {})
        api.post("/releases", params)
      end
    end
  end
end
