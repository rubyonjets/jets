# Authorizer public methods get turned into Lambda functions.
#
# Jets::Authorizer::Base < Jets::Lambda::Functions
# Both Jets::Authorizer::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Authorizer::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Authorizer
  class Base < Jets::Lambda::Functions
    include Dsl
    include Helpers::IamHelper

    class << self
      def process(event, context, meth)
        authorizer = new(event, context, meth)
        authorizer.send(meth)
      end

      # Parameter: authorizer: Example: "main#protect"
      #
      # Determines authorization_type based on whether the authorizer is a Lambda or Cognito authorizer.
      #
      # Returns custom or cognito_user_pools
      def authorization_type(authorizer)
        class_name, meth = authorizer.split('#')
        klass = "#{class_name}_authorizer".camelize.constantize
        meth = meth.to_sym

        # If there's a lambda function associated with the authorizer then it's a custom authorizer
        # Otherwise it's a cognito authorizer.
        #
        # Returns: Valid values: none, aws_iam, custom, cognito_user_pools, aws_cross_account_iam
        methods = klass.public_instance_methods(false)
        methods.include?(meth) ? :custom : :cognito_user_pools
      end
    end
  end
end
