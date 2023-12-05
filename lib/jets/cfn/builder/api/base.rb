module Jets::Cfn::Builder::Api
  class Base
    extend Memoist
    include Jets::Cfn::Builder::Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end
  end
end
