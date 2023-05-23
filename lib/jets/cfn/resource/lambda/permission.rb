# Resource: Permissions are at the cfn/resource/permission.rb level because the
# principal is determined by the calling or associated resource.
# IE: Principal: events.amazonaws.com for Jets Jobs.
module Jets::Cfn::Resource::Lambda
  class Permission < Jets::Cfn::Base
    def initialize(replacements, associated_resource, options={})
      @replacements = replacements
      @associated_resource = associated_resource
      # allow override for Jets::Cfn::Resource::Lambda::Function::Controller permission
      @principal = options[:Principal]
      @source_arn = options[:SourceArn]
    end

    def definition
      logical_id = permission_logical_id

      definition = {
        logical_id => {
          Type: "AWS::Lambda::Permission",
          Properties: {
            FunctionName: "!Ref {namespace}LambdaFunction",
            Action: "lambda:InvokeFunction",
            Principal: principal
          }
        }
      }

      # From AWS docs: https://amzn.to/2N0QXQL
      # source_arn is "not supported by all event sources"
      definition[logical_id][:Properties][:SourceArn] = source_arn if source_arn

      definition
    end

    def permission_logical_id
      logical_id = "{namespace}Permission"
      md = @associated_resource.logical_id.match(/(\d+)$/)
      counter = md[1] if md
      [logical_id, counter].compact.join('')
    end

    # Auto-detect principal from the associated resources.
    def principal
      @principal || replacer.principal_map(@associated_resource.type)
    end

    def source_arn
      @source_arn || replacer.source_arn_map(@associated_resource.type)
    end
  end
end
