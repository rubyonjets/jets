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
      return if @options[:stack_type] == :minimal

      puts "Building API Gateway Deployment template."
      add_parameter("RestApi", Description: "RestApi")

      map = Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.new(path=nil,s3_bucket=nil)
      add_resource(map.logical_id, "AWS::ApiGateway::Deployment",
        Description: "Version #{map.timestamp} deployed by jets",
        RestApiId: "!Ref RestApi",
        StageName: map.stage_name,
      )

      add_output("RestApiUrl", Value: "!Sub 'https://${RestApi}.execute-api.${AWS::Region}.amazonaws.com/#{map.stage_name}/'")
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
