module Jets::Cfn::Resource::Nested
  class OneController < Base
    # interface method
    def definition
      defintion = {
        JetsController: {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          }
        }
      }
      defintion
    end

    # override
    def template_filename
      "jets-controller.yml"
    end

    def parameters
      params = Jets::Cfn::Params::Common.parameters
      params.merge!(controller_params)
      params
    end

    def controller_params
      if Jets::Router.no_routes?
        {}
      else
        {
          RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
        }
      end
    end

    def authorizer_output(desc)
      authorizer_stack, authorizer_logical_id = desc.split('.')
      # IE: MainAuthorizer.Outputs.ProtectAuthorizer
      "#{authorizer_stack}.Outputs.#{authorizer_logical_id}"
    end

    def outputs
      {}
    end
  end
end
