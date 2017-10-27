class Jets::Cfn::Builder
  class Parent
    include Helpers
    include Jets::Cfn::AwsServices

    def initialize
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      puts "Building parent template"

      add_minimal_resources
      add_child_resources unless first_run
    end

    def template_path
      Jets::Cfn::Namer.parent_template_path
    end

    @@first_run = nil
    def first_run
      return true
      @@first_run ||= !stack_exists?(parent_stack_name)
    end

    def parent_stack_name
      "#{Jets::Project.project_name}-#{Jets::Project.env}"
    end

    def add_minimal_resources
      path = File.expand_path("../templates/minimal-stack.yml", __FILE__)
      minimal_template = YAML.load(IO.read(path))
      @template.deep_merge!(minimal_template)
    end

    def add_child_resources
      expression = "#{Jets::Cfn::Namer.template_prefix}-*"
      puts "expression #{expression.inspect}"
      Dir.glob(expression).each do |path|
        # next unless File.file?(path)
        puts "path #{path}".colorize(:red)

        # Child app stacks
        app = AppInfo.new(path)
        # app.logical_id - PostsController
        add_resource(app.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: app.template_url,
          Parameters: app.parameters,
          DependsOn: ["Base"]
        )
      end
    end
  end
end