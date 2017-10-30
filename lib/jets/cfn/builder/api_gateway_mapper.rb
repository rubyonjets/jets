class Jets::Cfn::Builder
  class ApiGatewayMapper < ChildMapper
    # Override parameters, Api Gateway child stack does not require any parameters
    # Method not used anyway but just in case it gets used in the future.
    def parameters
      {}
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
  end
end