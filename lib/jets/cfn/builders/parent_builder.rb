require 'erb'

class Jets::Cfn::Builders
  class ParentBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      puts "Building parent CloudFormation template."

      build_minimal_resources
      build_child_resources if @options[:force_full] || @options[:stack_type] == :full
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def build_minimal_resources
      # Initial s3 bucket, used to store code zipfile and templates Jets generates
      resource = Jets::Resource::S3.new
      add_resource(resource)
      add_outputs(resource.outputs)

      # Add application-wide IAM policy from Jets.config.iam_role
      resource = Jets::Resource::Iam::ApplicationRole.new
      add_resource(resource)
      add_outputs(resource.outputs)
    end

    def build_child_resources
      puts "Building child CloudFormation templates."

      expression = "#{Jets::Naming.template_path_prefix}-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-comments_controller.yml
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        next if api_gateway_paths.include?(path) # treated specially
        next if shared_resource?(path) # treated specially

        add_app_class_stack(path)
      end

      expression = "#{Jets::Naming.template_path_prefix}-shared-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-shared-resources.yml
      puts "expression #{expression}"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        add_shared_resources(path)
      end

      if (@options[:force_full] || @options[:stack_type] == :full) and !Jets::Router.routes.empty?
        add_api_gateway
        add_api_deployment
      end
    end

    def add_app_class_stack(path)
      resource = Jets::Resource::ChildStack::AppClass.new(@options[:s3_bucket], path: path)
      add_child_resources(resource)
    end

    def add_shared_resources(path)
      puts "add_shared_resources path #{path}"
      resource = Jets::Resource::ChildStack::Shared.new(@options[:s3_bucket], path: path)
      puts "resource.resources? #{resource.resources?}"
      add_child_resources(resource) if resource.resources?
    end

    def add_api_gateway
      resource = Jets::Resource::ChildStack::ApiGateway.new(@options[:s3_bucket])
      add_child_resources(resource)
    end

    def add_api_deployment
      resource = Jets::Resource::ChildStack::ApiDeployment.new(@options[:s3_bucket])
      add_child_resources(resource)
    end

    def add_child_resources(resource)
      add_resource(resource)
      add_outputs(resource.outputs)
    end

    def api_gateway_paths
      files = %w[
        api-deployment.yml
        api-gateway.yml
      ]
      files.map do |name|
        "#{Jets::Naming.template_path_prefix}-#{name}"
      end
    end

    def shared_resource?(path)
      path =~ /-shared-/
    end
  end
end
