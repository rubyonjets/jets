# Converts a Jets::Route to a CloudFormation resource
module Jets::Resource
  class Route
    autoload :Attributes, 'jets/resource/route/attributes'
    autoload :Cors, 'jets/resource/route/cors'

    extend Memoist

    # route - Jets::Route
    def initialize(route)
      @route = route
    end

    def attributes
      resource_id = @path == '' ?
        "RootApiResource" :
        "#{resource_logical_id}ApiResource"

      attributes = {
        "#{method_logical_id}ApiMethod" => {
          type: "AWS::ApiGateway::Method",
          properties: {
            http_method: @route.method,
            request_parameters: {},
            resource_id: "!Ref #{resource_id}",
            rest_api_id: "!Ref RestApi",
            authorization_type: "NONE",
            integration: {
              integration_http_method: "POST",
              type: "AWS_PROXY",
              uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${{namespace}LambdaFunction.Arn}/invocations"
            },
            method_responses: []
          }
        }
      }

      definitions = attributes # to emphasize that its the same thing
      task = Jets::Lambda::Task.new(@route.controller_name, @route.action_name,
               resources: definitions)
      Attributes.new(attributes, task)
    end
    alias_method :resource, :attributes
    memoize :attributes

  private
    # Similar path_logical_id method in template_mappers/gateway_resource_mapper.rb
    def method_logical_id
      path = @route.path
      path = path.gsub('/','_')
      path += "_#{@route.method}"
      path.gsub(':','').gsub('*','').camelize
    end

    def resource_logical_id
      path = @route.path
      path = path.gsub('/','_')
      path.gsub(':','').gsub('*','').camelize
    end
  end
end
