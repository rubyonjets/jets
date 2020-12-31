module Jets::Commands
  class Url
    include Jets::AwsServices

    def initialize(options)
      @options = options
    end

    def display
      stack_name = Jets::Naming.parent_stack_name
      unless stack_exists?(stack_name)
        puts "Stack for #{Jets.config.project_name.color(:green)} project for environment #{Jets.env.color(:green)}.  Couldn't find #{stack_name.color(:green)} stack."
        exit
      end

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")
      if api_gateway_stack_arn && endpoint_available?
        api_gateway_endpoint = get_gateway_endpoint(api_gateway_stack_arn)
        STDOUT.puts "API Gateway Endpoint: #{api_gateway_endpoint}"
        show_custom_domain
      else
        puts "API Gateway not found. This jets app does have an API Gateway associated with it.  Please double check your config/routes.rb if you were expecting to see a url for the app. Also check that #{stack_name.color(:green)} is a jets app."
      end
    end

    def get_gateway_endpoint(api_gateway_stack_arn)
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api = lookup(stack[:outputs], "RestApi")
      region_id = lookup(stack[:outputs], "Region")
      stage_name = Jets::Resource::ApiGateway::Deployment.stage_name

      # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html
      # https://my-api-id.execute-api.region-id.amazonaws.com/stage-name/{resourcePath}
      "https://#{rest_api}.execute-api.#{region_id}.amazonaws.com/#{stage_name}"
    end

    def show_custom_domain
      return unless endpoint_available? && Jets.custom_domain? && Jets.config.domain.route53

      domain_name = Jets::Resource::ApiGateway::DomainName.new
      # Looks funny but its right.
      # domain_name is a method on the Jets::Resource::ApiGateway::Domain instance
      url = "https://#{domain_name.domain_name}"
      puts "Custom Domain: #{url}"
      puts "App Domain: #{Jets.config.app.domain}" if Jets.config.app.domain
    end

    def endpoint_unavailable?
      return false if Jets::Router.routes.empty?
      resp, status = stack_status
      return false if status.include?("ROLLBACK")
    end

    def endpoint_available?
      !endpoint_unavailable?
    end

    # All CloudFormation states listed here:
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def stack_status
      resp = cfn.describe_stacks(stack_name: @parent_stack_name)
      status = resp.stacks[0].stack_status
      [resp, status]
    end

  end
end
