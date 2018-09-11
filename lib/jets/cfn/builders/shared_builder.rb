class Jets::Cfn::Builders
  class SharedBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == :minimal

      # deployment = Jets::Resource::ApiGateway::Deployment.new
      # add_resource(deployment)
      # add_parameters(deployment.parameters)
      # add_outputs(deployment.outputs)
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.shared_resources_template_path
    end

    # do not bother writing a template there are no shared resources
    def write
      super unless Jets::Resources.exist?
    end
  end
end
