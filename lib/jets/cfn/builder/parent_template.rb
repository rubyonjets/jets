class Jets::Cfn::Builder
  class ParentTemplate
    include Helpers
    include Jets::Cfn::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      puts "Building parent template"

      add_minimal_resources
      add_child_resources unless @options[:stack_type] == 'minimal'
      add_gateway_api
    end

    def template_path
      Jets::Cfn::Namer.parent_template_path
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
        next unless File.file?(path)
        puts "path #{path}".colorize(:red)

        # Child app stacks
        app = AppInfo.new(path, @options[:s3_bucket])
        # app.logical_id - PostsController
        add_resource(app.logical_id, "AWS::CloudFormation::Stack",
          TemplateURL: app.template_url,
          Parameters: app.parameters,
        )
      end
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_api
      return unless Jets::Build::RoutesBuilder.routes.size > 0

      add_resource("GatewayRestApi", "AWS::ApiGateway::RestApi",
        Name: Jets::Cfn::Namer.gateway_api_name
      )
    end
  end
end