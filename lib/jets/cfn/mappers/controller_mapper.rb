class Jets::Cfn::Mappers
  class ControllerMapper < ChildMapper
    # Parameters that are common to all controller stacks
    def parameters
      parameters = super

      # Add the API Gateway parameters
      parameters[:ApiGatewayRestApi] = "!GetAtt ApiGateway.Outputs.ApiGatewayRestApi"
      Jets::Build::Router.all_paths.each do |path|
        map = GatewayResourceMapper.new(path)
        parameters[map.logical_id] = "!GetAtt ApiGateway.Outputs.#{map.logical_id}"
      end

      parameters
    end
  end
end
