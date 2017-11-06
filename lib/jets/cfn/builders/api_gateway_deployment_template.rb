class Jets::Cfn::Builders
  class ApiGatewayDeploymentTemplate
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == 'minimal'

      puts "Building API Gateway Deployment template."
      add_parameter("ApiGatewayRestApi", Description: "ApiGatewayRestApi")

      logical_id = Jets::Cfn::Mappers::ApiGatewayDeploymentMapper.logical_id
      timestamp = Jets::Cfn::Mappers::ApiGatewayDeploymentMapper.timestamp
      # stage_name: stag, stag-1, stag-2, etc
      stage_name = [Jets.config.short_env, Jets.config.env_instance].compact.join('-')
      add_resource(logical_id, "AWS::ApiGateway::Deployment",
        Description: "Version #{timestamp} deployed by jets",
        RestApiId: "!Ref ApiGatewayRestApi",
        StageName: stage_name,
      )
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_deployment_template_path
    end
  end
end
