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
      add_child_resources unless @options[:stack_type] == :minimal
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def add_minimal_resources
      path = File.expand_path("../templates/minimal-stack.yml", __FILE__)
      rendered_result = Jets::Erb.result(path)
      minimal_template = YAML.load(rendered_result)
      @template.deep_merge!(minimal_template)

      # Add application-wide IAM policy from Jets.config.iam_role
      map = Jets::Cfn::TemplateMappers::IamPolicy::ApplicationPolicyMapper.new
      add_resource(map.logical_id, "AWS::IAM::Role", map.properties)
    end

    def add_child_resources
      expression = "#{Jets::Naming.template_path_prefix}-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-comments_controller.yml
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        next if path =~ /api-gateway/ # specially treated

        add_app_class_stack(path)
      end

      if @options[:stack_type] == :full and !Jets::Router.routes.empty?
        add_api_gateway
        add_api_deployment
      end
    end

    def add_app_class_stack(path)
      resource = Jets::Resource::ChildStack::AppClass.new(path, @options[:s3_bucket])
      build_child_resources(resource)
    end

    def add_api_gateway
      resource = Jets::Resource::ChildStack::ApiGateway.new(@options[:s3_bucket])
      build_child_resources(resource)
    end

    def add_api_deployment
      resource = Jets::Resource::ChildStack::ApiDeployment.new(@options[:s3_bucket])
      build_child_resources(resource)
    end

    def build_child_resources(resource)
      add_associated_resource(resource)
      add_outputs(resource.outputs)
    end
  end
end
