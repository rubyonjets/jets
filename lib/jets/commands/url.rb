module Jets::Commands
  class Url
    include Jets::AwsServices

    def initialize(options)
      @options = options
    end

    def display
      stack_name = Jets::Naming.parent_stack_name
      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      unless stack
        puts "Stack for '#{Jets.config.project_name} project for environment #{Jets.env}.  Couldn't find '#{stack_name}' stack."
        exit
      end

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")
      if api_gateway_stack_arn
        puts get_url(api_gateway_stack_arn)
      else
        puts "API Gateway not found. This jets app does have an API Gateway associated with it.  Please double check your config/routes.rb if you were expecting to see a url for the app."
      end
      byebug
      puts "hi"
    end

    def get_url(api_gateway_stack_arn)
      stacks = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks
      rest_api = lookup(stack[:outputs], "RestApi")
      rest_api = lookup(stack[:outputs], "Region")
      rest_api = output["RestApi"]
      # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html
      # https://my-api-id.execute-api.region-id.amazonaws.com/stage-name/{resourcePath}
      "https://#{rest_api}.execute-api.#{region_id}.amazonaws.com/stage-name/{resourcePath}"
    end

    # Lookup output value
    def lookup(outputs, key)
      output = outputs.find { |o| o.output_key == "ApiGateway" }
      output["ApiGateway"]
    end
  end
end
