module Jets::Commands
  class Url
    include Jets::AwsServices

    def initialize(options)
      @options = options
    end

    def display
      stack_name = Jets::Naming.parent_stack_name
      unless stack_exists?(stack_name)
        puts "Stack for #{Jets.config.project_name.colorize(:green)} project for environment #{Jets.env.colorize(:green)}.  Couldn't find #{stack_name.colorize(:green)} stack."
        exit
      end

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")
      if api_gateway_stack_arn
        STDOUT.puts get_url(api_gateway_stack_arn)
      else
        puts "API Gateway not found. This jets app does have an API Gateway associated with it.  Please double check your config/routes.rb if you were expecting to see a url for the app. Also check that #{stack_name.colorize(:green)} is a jets app."
      end
    end

    def get_url(api_gateway_stack_arn)
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api = lookup(stack[:outputs], "RestApi")
      region_id = lookup(stack[:outputs], "Region")
      stage_name = Jets::Resource::ApiGateway::Deployment.stage_name

      # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html
      # https://my-api-id.execute-api.region-id.amazonaws.com/stage-name/{resourcePath}
      "https://#{rest_api}.execute-api.#{region_id}.amazonaws.com/#{stage_name}"
    end

    # Lookup output value
    def lookup(outputs, key)
      out = outputs.find { |o| o.output_key == key }
      out&.output_value
    end
  end
end
