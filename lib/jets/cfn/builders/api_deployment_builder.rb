class Jets::Cfn::Builders
  class ApiDeploymentBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == :minimal

      deployment = Jets::Resource::ApiGateway::Deployment.new
      add_resource(deployment)
      add_parameters(deployment.parameters)
      add_outputs(deployment.outputs)
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_deployment_template_path
    end

    # do not bother writing a template if routes are empty
    def write
      super unless Jets::Router.routes.empty?
    end
  end
end
