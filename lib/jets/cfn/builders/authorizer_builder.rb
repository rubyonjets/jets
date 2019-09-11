# Implements:
#
#   compose
#   template_path
#
module Jets::Cfn::Builders
  class AuthorizerBuilder < BaseChildBuilder
    include Interface
    include Jets::AwsServices

    def initialize(path)
      @path = path # IE: app/authorizers/main_authorizer.rb
      @app_class = Jets::Klass.from_path(path)
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    def compose
      add_common_parameters
      add_api_gateway_parameters
      add_functions
      add_resources
      add_outputs
      # These dont have lambda functions associated with them
      add_cognito_authorizers
      add_cognito_outputs
    end

    def add_cognito_authorizers
      @app_class.cognito_authorizers.each do |authorizer|
        resource = Jets::Resource.new(authorizer[:definition], authorizer[:replacements])
        add_resource(resource)
      end
    end

    def add_outputs
      # IE: @app_class = MainAuthorizer
      # The associated resource is the Jets::Resource::ApiGateway::Authorizer definition built during evaluation
      # of the user defined Authorizer class. We'll use it to compute the logical id.
      @app_class.tasks.each do |task|
        authorizer = task.associated_resources.first
        next unless authorizer

        resource = Jets::Resource.new(authorizer.definition, task.replacements)
        logical_id = resource.logical_id
        add_output(logical_id, value: "!Ref #{logical_id}")
      end
    end

    def add_cognito_outputs
      @app_class.cognito_authorizers.each do |authorizer|
        resource = Jets::Resource.new(authorizer[:definition], authorizer[:replacements])
        logical_id = resource.logical_id
        add_output(logical_id, value: "!Ref #{logical_id}")
      end
    end

    def add_api_gateway_parameters
      return if Jets::Router.routes.empty?

      add_parameter("RestApi", Description: "RestApi")
    end

    def template_path
      Jets::Naming.authorizer_template_path(@path)
    end
  end
end
