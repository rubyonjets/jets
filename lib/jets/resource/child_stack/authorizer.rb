module Jets::Resource::ChildStack
  class Authorizer < Base
    include CommonParameters

    def initialize(s3_bucket, options={})
      super
      @path = options[:path]
    end

    def definition
      logical_id = authorizer_logical_id
      {
        logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
            parameters: parameters,
          }
        }
      }
    end

    def parameters
      params = common_parameters
      params[:RestApi] = "!GetAtt ApiGateway.Outputs.RestApi"
      params
    end

    # map the path to a camelized logical_id. IE: ProtectAuthorizer
    def authorizer_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-authorizers-")
      authorizer_name = @path.sub(regexp, '').sub('.yml', '')
      authorizer_name.underscore.camelize
    end

    def template_filename
      @path
    end
  end
end
