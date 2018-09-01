module Jets::Resource
  class Permission
    extend Memoist

    def initialize(task)
      @task = task
    end

    # Replacements occur for: logical_id, function_name, principal, source_arn
    def resource
      attributes = {
        "{namespace}Permission" => {
          type: "AWS::Lambda::Permission",
          properties: {
            function_name: "!GetAtt {namespace}LambdaFunction.Arn",
            action: "lambda:InvokeFunction",
            principal: principal,
            source_arn: source_arn,
          }
        }
      }
      Attributes.new(attributes, @task)
    end
    memoize :resource

    # SourceArn: !GetAtt SecurityJobDisableUnusedCredentialsScheduledEvent.Arn
    #
    # TODO: The API Gateway SourceArn is a different beast, maybe dont handle with
    # generic resource at all.
    # SourceArn: !Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*
    def source_arn
      source_arns = @task.resources.map do |definition|
        creator = Jets::Resource::Creator.new(definition, @task)
        source_arn_map(creator.resource.type, creator.resource.logical_id)
      end
      source_arns.size == 1 ? source_arns.first : source_arns
    end

    # Auto-detect principal from the associated resources.
    def principal
      principals = @task.resources.map do |definition|
        creator = Jets::Resource::Creator.new(definition, @task)
        principal_map[creator.resource.type]
      end
      principals.size == 1 ? principals.first : principals
    end

    ##################################
    # Maps
    # TODOs:
    # * fill out these maps, logical_id to service principal map.
    # * add ability to explicitly override principal and source_arn.
    def principal_map
      {
        "AWS::Events::Rule" => "events.amazonaws.com",
      }
    end

    def source_arn_map(type, associated_resource_id)
      map = {
        "AWS::Events::Rule" => "!GetAtt #{associated_resource_id}.Arn",
      }
      map[type]
    end
  end
end
