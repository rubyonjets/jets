class Jets::Cfn::TemplateBuilders
  class ApiGatewayDeploymentBuilder
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
      add_parameter("RestApi", Description: "RestApi")

      logical_id = Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.logical_id
      timestamp = Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.timestamp
      # stage_name: stag, stag-1, stag-2, etc
      stage_name = [Jets.config.short_env, Jets.config.env_instance].compact.join('_').gsub('-','_') # Stage name only allows a-zA-Z0-9_
      add_resource(logical_id, "AWS::ApiGateway::Deployment",
        Description: "Version #{timestamp} deployed by jets",
        RestApiId: "!Ref RestApi",
        StageName: stage_name,
      )
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_deployment_template_path
    end

    # do not bother writing a template if routes are empty
    def write
      super unless Jets::Router.routes.empty?
    end
  end
end
