class Jets::Cfn::TemplateMappers
  class ControllerMapper < ChildMapper
    # Parameters that are common to all controller stacks
    def parameters
      parameters = super
      return parameters if Jets::Router.routes.empty?

      # Add the API Gateway parameters
      parameters[:RestApi] = "!GetAtt ApiGateway.Outputs.RestApi"
      Jets::Router.all_paths.each do |path|
        map = GatewayResourceMapper.new(path)
        parameters[map.logical_id] = "!GetAtt ApiGateway.Outputs.#{map.logical_id}"
      end

      parameters
    end
  end
end
