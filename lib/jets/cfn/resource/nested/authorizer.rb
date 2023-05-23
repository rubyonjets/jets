module Jets::Cfn::Resource::Nested
  class Authorizer < Base
    def initialize(options={})
      super
      @path = options[:path]
    end

    def definition
      logical_id = authorizer_logical_id
      {
        logical_id => {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          }
        }
      }
    end

    def parameters
      params = Jets::Cfn::Params::Common.parameters
      params[:RestApi] = "!GetAtt ApiGateway.Outputs.RestApi"
      params
    end

    # map the path to a camelized logical_id. IE: ProtectAuthorizer
    def authorizer_logical_id
      regexp = Regexp.new("#{Jets::Names.templates_folder}/authorizers-")
      authorizer_name = @path.sub(regexp, '').sub('.yml', '')
      authorizer_name.underscore.camelize
    end
  end
end
