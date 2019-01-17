# Detects route changes
class Jets::Resource::ApiGateway::RestApi::Routes
  class Change
    autoload :Base, 'jets/resource/api_gateway/rest_api/routes/change/base'
    autoload :To, 'jets/resource/api_gateway/rest_api/routes/change/to'
    autoload :Variable, 'jets/resource/api_gateway/rest_api/routes/change/variable'

    def changed?
      To.changed? || Variable.changed? || ENV['JETS_REPLACE_API']
    end
  end
end
