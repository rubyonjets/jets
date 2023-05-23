module Jets::Cfn::Builder::Api
  class Mapping < Base
    # interface method
    def compose
      add_parameters(parameters)
      add_base_path_mapping
    end

    def parameters
      p = {
        GemLayer: "GemLayer",
        IamRole: "IamRole",
        RestApi: "RestApi",
        S3Bucket: "S3Bucket",
      }
      p[:DomainName] = "DomainName" if Jets.custom_domain?
      p[:BasePath] = "BasePath"
      p
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
      function = Jets::Cfn::Resource::ApiGateway::BasePath::Function.new
      add_resource(function)
      add_outputs(function.outputs)

      mapping = Jets::Cfn::Resource::ApiGateway::BasePath::Mapping.new
      add_resource(mapping)
      add_outputs(mapping.outputs)

      iam_role = Jets::Cfn::Resource::ApiGateway::BasePath::Role.new
      add_resource(iam_role)
      add_outputs(iam_role.outputs)
    end

    # interface method
    def template_path
      Jets::Names.api_mapping_template_path
    end

    # do not write a template unless custom domain is used
    def write
      super if Jets.custom_domain?
    end
  end
end
