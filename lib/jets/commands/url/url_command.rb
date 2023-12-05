module Jets::Command
  class UrlCommand < Base # :nodoc:
    option :format, aliases: :f, desc: "Output format: json or text", default: "text"

    desc "url", "App url if routes are defined"
    long_desc Help.text(:url)
    def url(*)
      Url.new(options).display
    end
  end

  class Url
    include Jets::AwsServices

    def initialize(options)
      @options = options
    end

    def display
      Jets.boot
      stack_name = Jets::Names.parent_stack_name
      unless stack_exists?(stack_name)
        $stderr.puts "Stack for #{Jets.project_name.color(:green)} project for environment #{Jets.env.color(:green)}.  Couldn't find #{stack_name.color(:green)} stack."
        exit 1
      end

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      data = {}

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")
      if api_gateway_stack_arn && endpoint_available?
        data[:api_gateway_endpoint] = get_gateway_endpoint(api_gateway_stack_arn)
        get_custom_domain!(data)
      end

      if data.empty?
        $stderr.puts "API Gateway not found. This jets app does have an API Gateway associated with it.  Please double check your config/routes.rb if you were expecting to see a url for the app. Also check that #{stack_name.color(:green)} is a jets app."
        exit 1
      end

      if @options[:format] == "json"
        puts data.to_json
      else
        puts "API Gateway Endpoint: #{data[:api_gateway_endpoint]}"
        puts "Custom Domain: #{data[:custom_domain]}" if data[:custom_domain]
        puts "App Domain: #{data[:app_domain]}" if data[:app_domain]
      end
    end

    def get_gateway_endpoint(api_gateway_stack_arn)
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api = lookup(stack[:outputs], "RestApi")
      region_id = lookup(stack[:outputs], "Region")
      stage_name = Jets::Cfn::Resource::ApiGateway::Deployment.stage_name

      # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html
      # https://my-api-id.execute-api.region-id.amazonaws.com/stage-name/{resourcePath}
      "https://#{rest_api}.execute-api.#{region_id}.amazonaws.com/#{stage_name}"
    end

    def get_custom_domain!(data)
      return unless endpoint_available? && Jets.custom_domain? && Jets.config.domain.route53

      domain_name = Jets::Cfn::Resource::ApiGateway::DomainName.new
      # Looks funny but its right.
      # domain_name is a method on the Jets::Cfn::Resource::ApiGateway::Domain instance
      url = "https://#{domain_name.domain_name}"
      data[:custom_domain] = url
      data[:app_domain] = "https://#{Jets.config.app.domain}" if Jets.config.app.domain
    end

    def endpoint_unavailable?
      return false if Jets::Router.no_routes?
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
