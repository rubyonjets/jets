class Jets::Cfn::Builder
  class GatewayDeploymentMapper
    # Returns: "ApiGatewayDeployment"
    @@gateway_deployment_logical_id = nil
    def gateway_deployment_logical_id
      return @@gateway_deployment_logical_id if @@gateway_deployment_logical_id

      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      @@gateway_resource_logical_id = "ApiGatewayDeployment#{timestamp}"
    end

    def common_logical_id
      path_logical_id(@path)
    end
  end
end