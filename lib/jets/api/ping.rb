module Jets::Api
  class Ping < Base
    class << self
      def create(params = {})
        api.post("/pings", params)
      end
    end
  end
end
