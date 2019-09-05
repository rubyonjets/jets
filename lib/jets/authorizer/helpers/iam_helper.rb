module Jets::Authorizer::Helpers
  module IamHelper
  private
    # Structure: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-lambda-authorizer-output.html
    # Example:
    #
    #     {
    #       "principalId" => "yyyyyyyy", // The principal user identification associated with the token sent by the client.
    #       "policyDocument" => {},
    #       "context" => {},
    #       "usageIdentifierKey" => "{api-key}"
    #     }
    #
    def build_policy(*args)
      if args.first.is_a?(Hash) # generalized form
        props = args.first
      else # build_policy(resource, principal, context, usage_identifier_key) form
        resource, principal_id, context, usage_identifier_key = args
        props = {
          principal_id: principal_id || "default_user",
          policy_document: {
            version: "2012-10-17",
            statement: [
              action: "execute-api:Invoke",
              effect: "Allow",
              resource: resource || "*",
            ],
          },
        }
        props[:context] = context if context
        props[:usage_identifier_key] = usage_identifier_key if usage_identifier_key
      end

      props = Jets::Camelizer.transform(props) # keys get converted from Symbols to Strings as part of this
      # Only top-level keys and keys under context are pascalized
      props.transform_keys! { |k| pascalize(k) }
      if props['context']
        props['context'].transform_keys! { |k| pascalize(k) }
      end
      props
    end

    def pascalize(value)
      new_value = value.camelize
      first_char = new_value[0..0].downcase
      new_value[0] = first_char
      new_value
    end
  end
end
