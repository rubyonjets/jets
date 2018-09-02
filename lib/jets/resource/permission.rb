module Jets::Resource
  class Permission
    extend Memoist

    def initialize(task, resource)
      @task = task
      @resource = resource
    end

    # Replacements occur for: logical_id, function_name, principal, source_arn
    def attributes
      logical_id = "{namespace}Permission"
      md = @resource.logical_id.match(/(\d+)/)
      if md
        counter = md[1]
      end
      logical_id = [logical_id, counter].compact.join('')

      attributes = {
        logical_id => {
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
    memoize :attributes

    # SourceArn: !GetAtt SecurityJobDisableUnusedCredentialsScheduledEvent.Arn
    #
    # TODO: The API Gateway SourceArn is a different beast, maybe dont handle with
    # generic resource at all.
    # SourceArn: !Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*
    def source_arn
      source_arn_map(@resource.type, @resource.logical_id)
    end

    # Auto-detect principal from the associated resources.
    def principal
      principal_map[@resource.type]
    end

    ##################################
    # Maps
    # TODOs:
    # * fill out these maps, logical_id to service principal map.
    # * add ability to explicitly override principal and source_arn.
    def principal_map
      {
        "AWS::Events::Rule" => "events.amazonaws.com",
        "AWS::Config::ConfigRule" => "config.amazonaws.com",
      }
    end

    def source_arn_map(type, associated_resource_id)
      map = {
        "AWS::Events::Rule" => "!GetAtt #{associated_resource_id}.Arn",
        "AWS::Config::ConfigRule" => "!GetAtt #{associated_resource_id}.Arn",
      }
      map[type]
    end
  end
end
