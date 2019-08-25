class Jets::Resource::ApiGateway::RestApi
  class ChangeDetection
    extend Memoist
    include Jets::AwsServices

    def changed?
      Routes.changed?
    end
  end
end
