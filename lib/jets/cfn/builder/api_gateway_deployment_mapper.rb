class Jets::Cfn::Builder
  class ApiGatewayDeploymentMapper < ChildMapper
    def gateway_deployment_logical_id
      self.class.gateway_deployment_logical_id
    end

    def parameters
      {
        ApiGatewayRestApi: "!GetAtt ApiGateway.Outputs.ApiGatewayRestApi"
      }
    end

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*-controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        # @s3_bucket is available from the inherited ChildMapper class
        map = ChildMapper.new(path, @s3_bucket)
        controller_logical_ids << map.logical_id
      end
      controller_logical_ids
    end

    def common_logical_id
      path_logical_id(@path)
    end

    # Returns: "ApiGatewayDeployment[timestamp]"
    def self.gateway_deployment_logical_id
      "ApiGatewayDeployment#{timestamp}"
    end

    @@timestamp = nil
    def self.timestamp
      @@timestamp ||= Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end