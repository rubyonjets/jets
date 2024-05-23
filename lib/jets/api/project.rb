module Jets::Api
  class Project < Base
    class << self
      def list(params = {})
        api.get("/projects", params)
      end
    end
  end
end
