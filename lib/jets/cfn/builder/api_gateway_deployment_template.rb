class Jets::Cfn::Builder
  class ApiGatewayDeploymentTemplate
    include Helpers
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == 'minimal'

      puts "Building API Gateway Deployment template"
      add_parameter("ApiGatewayRestApi", Description: "ApiGatewayRestApi")

      logical_id = ApiGatewayDeploymentMapper.gateway_deployment_logical_id
      timestamp = ApiGatewayDeploymentMapper.timestamp
      add_resource(logical_id, "AWS::ApiGateway::Deployment",
        Description: "Version #{timestamp} deployed by jets",
        RestApiId: "!Ref ApiGatewayRestApi",
        StageName: Jets::Config.env,
      )
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_deployment_template_path
    end
  end
end
