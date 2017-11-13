require 'erb'

class Jets::Cfn::TemplateBuilders
  class ParentBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      puts "Building parent template."

      add_minimal_resources
      add_child_resources unless @options[:stack_type] == 'minimal'
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def add_minimal_resources
      # variables for minimal-stack.yml
      path = File.expand_path("../templates/minimal-stack.yml", __FILE__)
      variables = {
        policy_name: "lamdba-#{Jets.config.project_namespace}-policy",
        role_name: "lamdba-#{Jets.config.project_namespace}-role",
      }
      rendered_result = Jets::Erb.result(path, variables)
      minimal_template = YAML.load(rendered_result)

      # minimal_template = YAML.load(IO.read(path))
      @template.deep_merge!(minimal_template)
    end

    def add_child_resources
      expression = "#{Jets::Naming.template_path_prefix}-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-comments_controller.yml
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        next if path =~ /api-gateway/ # treated specially

        mapper_class_name = File.basename(path, '.yml').split('_').last.classify # Controller or Job
        mapper_class = "Jets::Cfn::TemplateMappers::#{mapper_class_name}Mapper".constantize # ControllerMapper or JobMapper
        map = mapper_class.new(path, @options[:s3_bucket])

        # map.logical_id - PostsController
        add_resource(map.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: map.template_url,
          Parameters: map.parameters,
        )
      end

      if @options[:stack_type] == 'full' and !Jets::Router.routes.empty?
        add_api_gateway
        add_api_gateway_deployment
      end
    end

    # Each shared stacks has different logic.
    # Handle in ugly case statement until we see the common patterns between them.
    # TODO: clean up the add_shared_stack logical after we figure out the common interface pattern
    def add_api_gateway
      path = "#{Jets.config.project_namespace}-api-gateway.yml"
      map = Jets::Cfn::TemplateMappers::ApiGatewayMapper.new(path, @options[:s3_bucket])
      add_resource(map.logical_id, "AWS::CloudFormation::Stack",
        Properties: { TemplateURL: map.template_url }
      )
    end

    def add_api_gateway_deployment
      path = "#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      map = Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.new(path, @options[:s3_bucket])
      add_resource(map.logical_id, "AWS::CloudFormation::Stack",
        Properties: {
          TemplateURL: map.template_url,
          Parameters: map.parameters
        },
        DependsOn: map.depends_on
      )
    end
  end
end
