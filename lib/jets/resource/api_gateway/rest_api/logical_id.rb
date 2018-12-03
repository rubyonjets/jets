class Jets::Resource::ApiGateway::RestApi
  class LogicalId
    extend Memoist
    include Jets::AwsServices

    def get
      return default unless stack_exists?(parent_stack_name) && api_gateway_exists?

      change_detection = ChangeDetection.new
      if change_detection.changed?
        new_id
      else
        current
      end
    end

    # Takes current logical id and increments the number that is appended to it.
    #
    # Examples:
    #
    #   RestApi => RestApi1
    #   RestApi1 => RestApi2
    #   RestApi2 => RestApi3
    #   RestApi7 => RestApi8
    def new_id
      regexp = /(\d+)/
      md = current.match(regexp)
      if md
        current.gsub(regexp,'') + (md[1].to_i + 1).to_s
      else
        current + "1"
      end
    end

    def current
      resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      rest_api = resources.find { |r| r.resource_type == 'AWS::ApiGateway::RestApi' }
      rest_api.logical_resource_id
    end
    memoize :current

    def api_gateway_stack_arn
      stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first
      lookup(stack[:outputs], "ApiGateway") # api_gateway_stack_arn
    end

    def api_gateway_exists?
      !!api_gateway_stack_arn
    end

    def parent_stack_name
      Jets::Naming.parent_stack_name
    end

    def default
      "RestApi"
    end
  end
end
