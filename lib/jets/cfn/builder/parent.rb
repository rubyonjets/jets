class Jets::Cfn::Builder
  class Parent
    include Interface
    include Jets::AwsServices
    include Stagger

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # interface method
    def compose
      build_minimal_resources
      build_child_resources
    end

    # interface method
    def template_path
      Jets::Names.parent_template_path
    end

    def build_minimal_resources
      add_description("Jets: #{Jets.version} Code: #{Util::Source.version}")

      # Initial s3 bucket, used to store code zipfile and templates Jets generates
      #
      # AWS changed the default behavior of s3 buckets to block public access
      #   https://aws.amazon.com/blogs/aws/amazon-s3-block-public-access-another-layer-of-protection-for-your-accounts-and-buckets/
      #   https://github.com/aws-amplify/amplify-cli/issues/12503
      #
      # Jets uploads assets to s3 bucket with acl: "public-read" here
      #   https://github.com/boltops-tools/jets/blob/c5858ec2706a606665a92c3ada3f16ae4c753372/lib/jets/cfn/upload.rb#L97
      #
      # Use minimal s3 bucket policy to allow public read access to assets.
      # Leave the other options as comments to help document the default behavior.
      resource = Jets::Cfn::Resource::S3::JetsBucket.new
      add_resource(resource)
      add_outputs(resource.outputs)

      return unless full?
      # Add application-wide IAM policy from Jets.config.iam_role
      resource = Jets::Cfn::Resource::Iam::ApplicationRole.new
      add_resource(resource)
      add_outputs(resource.outputs)

      return unless Jets.build_gem_layer?
      resource = Jets::Cfn::Resource::Lambda::GemLayer.new
      add_resource(resource)
      add_outputs(resource.outputs)
    end

    def build_child_resources
      return unless full?

      add_one_lambda_controller if Jets.one_lambda_for_all_controllers? && Jets.config.mode != "job"
      for_each_path(:app) do |path|
        add_app_class_stack(path)
      end
      for_each_path(:shared) do |path|
        add_shared_resources(path)
      end

      return if Jets::Router.no_routes?
      for_each_path(:authorizers) do |path|
        add_authorizer_resources(path)
      end
      add_api_gateway
      add_api_resources
      add_api_methods
      add_api_deployment
      add_api_mapping
    end

    def full?
      @options[:stack_type] == :full
    end

    def add_one_lambda_controller
      resource = Jets::Cfn::Resource::Nested::OneController.new(@options)
      add_child_resources(resource)
    end

      # Example paths:
    #    #{Jets.build_root}/templates/shared-resources.yml
    #    #{Jets.build_root}/templates/app-comments_controller.yml
    #    #{Jets.build_root}/templates/authorizers-main_authorizer.yml
    def for_each_path(type)
      expression = "#{Jets::Names.templates_folder}/#{type}-*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)
        yield(path)
      end
    end

    def add_app_class_stack(path)
      resource = Jets::Cfn::Resource::Nested::AppClass.new(@options.merge(path: path))
      add_stagger(resource)
      add_child_resources(resource)
    end

    def add_authorizer_resources(path)
      resource = Jets::Cfn::Resource::Nested::Authorizer.new(@options.merge(path: path))
      add_child_resources(resource)
    end

    def add_shared_resources(path)
      resource = Jets::Cfn::Resource::Nested::Shared.new(@options.merge(path: path))
      add_child_resources(resource) if resource.resources?
    end

    def add_api_gateway
      resource = Jets::Cfn::Resource::Nested::Api::Gateway.new(@options)
      add_child_resources(resource)
    end

    def add_api_resources
      pages = Api::Pages::Resources.pages
      pages.each do |page|
        resource = Jets::Cfn::Resource::Nested::Api::Resources.new(@options.merge(page_number: page.number))
        add_child_resources(resource)
      end
    end

    def add_api_methods
      pages = Api::Pages::Methods.pages
      pages.each do |page|
        resource = Jets::Cfn::Resource::Nested::Api::Methods.new(@options.merge(page_number: page.number))
        add_child_resources(resource)
      end
    end

    def add_api_deployment
      resource = Jets::Cfn::Resource::Nested::Api::Deployment.new(@options)
      add_child_resources(resource)
    end

    def add_api_mapping
      return unless Jets.custom_domain?
      resource = Jets::Cfn::Resource::Nested::Api::Mapping.new(@options)
      add_child_resources(resource)
    end

    def add_child_resources(resource)
      add_resource(resource)
      add_outputs(resource.outputs)
    end
  end
end
