require 'active_support'
require 'active_support/core_ext/class'

# Jets::Authorizer::Base < Jets::Lambda::Functions
# Both Jets::Authorizer::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Authorizer::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#
#   default_associated_resource_definition
#
module Jets::Authorizer
  module Dsl
    extend ActiveSupport::Concern

    class_methods do
      include Jets::Util::Camelize

      def authorizer(props={})
        camelize(props)
        if props[:Type].to_s.upcase == "COGNITO_USER_POOLS"
          cognito_authorizer(props)
        else
          lambda_authorizer(props)
        end
      end

      def lambda_authorizer(props={})
        with_fresh_properties(multiple_resources: false) do
          r = Jets::Cfn::Resource::ApiGateway::Authorizer.new(props)
          resource(r.definition) # add associated resource immediately
        end
      end

      # Creates a definition but registers it to cognito_authorizers instead of all_tasks because there is no Lambda
      # function associated with the cognito authorizer.
      def cognito_authorizer(props={})
        camelize(props)
        resources = [props]
        # Authorizer name can have dashes, but "method" name should be underscored for correct logical id.
        meth = props[:Name].gsub('-','_')
        resource = Jets::Cfn::Resource::ApiGateway::Authorizer.new(props)

        # Mimic definition to grab base_replacements, namely namespace.
        # Do not actually use the definition to create a Lambda function for cognito authorizer.
        # Only using the definition for base_replacements.
        definition = Jets::Lambda::Definition.new(self.name, meth,
                 resources: resources,
                 replacements: {}) # No need for need additional replacements. Baseline replacements suffice
        all_cognito_authorizers[name] = { definition: resource.definition, replacements: definition.replacements }
        clear_properties
      end

      def all_cognito_authorizers
        @all_cognito_authorizers ||= ActiveSupport::OrderedHash.new
      end

      def cognito_authorizers
        all_cognito_authorizers.values
      end

      def build?
        !definitions.empty? || !all_cognito_authorizers.empty?
      end
    end

    included do
      class << self
        include Jets::AwsServices
      end
    end
  end
end