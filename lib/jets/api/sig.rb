module Jets::Api
  class Sig < Base
    class << self
      def create(params = {})
        api.post("/sigs", params)
      end

      def update(id, params = {})
        api.put("sigs/#{id}", params)
      end
    end
  end
end
