class Jets::Cfn::Builder
  class ParentTemplate
    include Helpers
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      puts "Building parent template"

      add_minimal_resources
      add_child_resources unless @options[:stack_type] == 'minimal'
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def add_minimal_resources
      path = File.expand_path("../templates/minimal-stack.yml", __FILE__)
      minimal_template = YAML.load(IO.read(path))
      @template.deep_merge!(minimal_template)
    end

    def add_child_resources
      expression = "#{Jets::Naming.template_prefix}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        map = ChildMapper.new(path, @options[:s3_bucket])
        # map.logical_id - PostsController
        parameters = {}
        parameters = map.parameters unless shared_stack?(path)
        add_resource(map.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: map.template_url,
          Parameters: parameters,
        )
      end
    end

    def shared_stacks
      %w[api-gateway]
    end

    def shared_stack?(path)
      !!shared_stacks.find { |p| path.include?(p) }
    end
  end
end