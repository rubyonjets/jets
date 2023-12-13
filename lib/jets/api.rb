module Jets
  module Api
    extend Memoist
    extend self

    def api
      Jets::Api::Client.new
    end
    memoize :api

    def api_key
      Jets::Api::Config.instance.api_key
    end
  end
end

require "jets/api/error" # load all error classes
