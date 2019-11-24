require 'erb'

module Jets::Cfn::Builders
  class ParentBuilder
    include Interface
    include Jets::AwsServices
    include Stagger

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      build_minimal_resources
      build_child_resources if full?
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.parent_template_path
    end

    def build_minimal_resources
      add_description("Jets: #{Jets.version} Code: #{Util::Source.version}")

      # Initial s3 bucket, used to store code zipfile and templates Jets generates
      resource = Jets::Resource::S3::Bucket.new(logical_id: "s3_bucket",
        bucket_encryption: {
          server_side_encryption_configuration: [
            server_side_encryption_by_default: {
              sse_algorithm: "AES256"
          }]}
      )
      add_resource(resource)
      add_outputs(resource.outputs)

      return unless full?
      # Add application-wide IAM policy from Jets.config.iam_role
      resource = Jets::Resource::Iam::ApplicationRole.new
      add_resource(resource)
      add_outputs(resource.outputs)

      return if Jets.poly_only?
      resource = Jets::Resource::Lambda::GemLayer.new
      add_resource(resource)
      add_outputs(resource.outputs)
    end

    def build_child_resources
      for_each_path(:app) do |path|
        add_app_class_stack(path)
      end
      for_each_path(:shared) do |path|
        add_shared_resources(path)
      end

      if full? and !Jets::Router.routes.empty?
        for_each_path(:authorizers) do |path|
          add_authorizer_resources(path)
        end
        add_api_gateway
        add_api_resources
        add_api_deployment
      end
    end

    # Example paths:
    #    #{Jets.build_root}/templates/demo-dev-2-shared-resources.yml
    #    #{Jets.build_root}/templates/demo-dev-2-app-comments_controller.yml
    #    #{Jets.build_root}/templates/demo-dev-2-authorizers-main_authorizer.yml
    def for_each_path(type)
      expression = "#{Jets::Naming.template_path_prefix}-#{type}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        yield(path)
      end
    end

    def full?
      @options[:templates] || @options[:stack_type] == :full
    end

    def add_app_class_stack(path)
      resource = Jets::Resource::ChildStack::AppClass.new(@options[:s3_bucket], path: path)
      add_stagger(resource)
      add_child_resources(resource)
    end

    def add_authorizer_resources(path)
      resource = Jets::Resource::ChildStack::Authorizer.new(@options[:s3_bucket], path: path)
      add_child_resources(resource)
    end

    def add_shared_resources(path)
      resource = Jets::Resource::ChildStack::Shared.new(@options[:s3_bucket], path: path)
      add_child_resources(resource) if resource.resources?
    end

    def add_api_gateway
      resource = Jets::Resource::ChildStack::ApiGateway.new(@options[:s3_bucket])
      add_child_resources(resource)
    end

    def add_api_resources
      expression = "#{Jets::Naming.template_path_prefix}-api-resources-*"
      # IE: path: #{Jets.build_root}/templates/demo-dev-2-api-resources-1.yml"
      Dir.glob(expression).sort.each do |path|
        next unless File.file?(path)

        regexp = Regexp.new("#{Jets.config.project_namespace}-api-resources-(\\d+).yml") # tricky to escape \d pattern
        md = path.match(regexp)
        page = md[1]
        resource = Jets::Resource::ChildStack::ApiResource.new(@options[:s3_bucket], page: page)
        add_child_resources(resource)
      end
    end

    def add_api_deployment
      resource = Jets::Resource::ChildStack::ApiDeployment.new(@options[:s3_bucket])
      add_child_resources(resource)
    end

    def add_child_resources(resource)
      add_resource(resource)
      add_outputs(resource.outputs)
    end
  end
end
