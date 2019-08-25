class Jets::Resource::ChildStack::ApiResource
  # Find the ApiResource Page that contains the AWS::ApiGateway::Resource
  # Returns: logical id of ApiResource Page
  class Page
    def self.logical_id(parameter)
      expression = "#{Jets::Naming.template_path_prefix}-api-resources-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-api-resources-1.yml"
      template_paths = Dir.glob(expression).sort.to_a
      found_template = template_paths.detect do |path|
        next unless File.file?(path)

        template = Jets::Cfn::BuiltTemplate.get(path)
        template['Outputs'].keys.include?(parameter)
      end
      md = found_template.match(/-(api-resources-\d+)/)

      md[1].underscore.camelize # IE: ApiResources1
    end
  end
end
