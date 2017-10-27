class Jets::Cfn::Builder
  class Parent
    include Helpers

    def initialize
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      puts "Building parent template"
      add_output("S3Bucket")
      add_output("IamRole")
      add_child_resources
    end

    def add_child_resources
      expression = "#{Jets::Cfn::Namer.template_path_base}-*"
      puts "expression #{expression.inspect}"
      Dir.glob(expression).each do |path|
        # next unless File.file?(path)
        puts "path #{path}".colorize(:red)

        child = ChildInfo.new(path)
        # child.logical_id - PostsController
        add_resource(child.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: child.template_url,
          Parameters: child.parameters
        )
      end
    end

    def write
      template_path = Jets::Cfn::Namer.parent_template_path
      puts "writing parent stack template #{template_path}"
      FileUtils.mkdir_p(File.dirname(template_path))
      IO.write(template_path, text)
    end
  end
end