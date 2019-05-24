# Detects route changes
class Jets::Resource::ApiGateway::RestApi::Routes
  class Change
    def changed?
      To.changed? || Variable.changed? || ENV['JETS_REPLACE_API']
    end
  end
end
