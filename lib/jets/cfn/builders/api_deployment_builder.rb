module Jets::Cfn::Builders
  class ApiDeploymentBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      deployment = Jets::Resource::ApiGateway::Deployment.new
      add_resource(deployment)
      add_parameters(deployment.parameters)
      add_outputs(deployment.outputs)

      add_base_path_mapping
    end

    # Because Jets generates a new timestamped logical id for the API Deployment
    # resource it also creates a new root base path mapping and fails.  Additionally,
    # the base path mapping depends on the API Deploy for the stage name.
    #
    # We resolve this by using a custom resource that does an in-place update.
    #
    # Note, also tried to change the domain name of to something like demo-dev-[random].mydomain.com
    # but that does not work because the domain name has to match the route53 record exactly.
    #
    def add_base_path_mapping
      return unless Jets.custom_domain?

      function = Jets::Resource::ApiGateway::BasePath::Function.new
      add_resource(function)
      add_outputs(function.outputs)

      mapping = Jets::Resource::ApiGateway::BasePath::Mapping.new
      add_resource(mapping)
      add_outputs(mapping.outputs)

      iam_role = Jets::Resource::ApiGateway::BasePath::Role.new
      add_resource(iam_role)
      add_outputs(iam_role.outputs)
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
