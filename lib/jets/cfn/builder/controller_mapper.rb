class Jets::Cfn::Builder
  class ControllerMapper < ChildMapper
    # Parameters that are common to all controller stacks
    def parameters
      parameters = super

      # Add the API Gateway parameters
      parameters[:ApiGatewayRestApi] = "!GetAtt ApiGateway.Outputs.ApiGatewayRestApi"
      Jets::Build::RoutesBuilder.all_paths.each do |path|
        map = GatewayResourceMapper.new(path)
        parameters[map.gateway_resource_logical_id] = "!GetAtt ApiGateway.Outputs.#{map.gateway_resource_logical_id}"
      end

      parameters
    end
  end
end