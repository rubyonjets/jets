class Jets::Cfn::TemplateMappers
  class ApiGatewayDeploymentMapper < ChildMapper
    def logical_id
      self.class.logical_id
    end

    def parameters
      {
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi"
      }
    end

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        # @s3_bucket is available from the inherited ChildMapper class
        map = ChildMapper.new(path, @s3_bucket)
        controller_logical_ids << map.logical_id
      end
      controller_logical_ids
    end

    # Returns: "ApiGatewayDeployment[timestamp]"
    def self.logical_id
      "ApiGatewayDeployment#{timestamp}"
    end

    @@timestamp = nil
    def self.timestamp
      @@timestamp ||= Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end
