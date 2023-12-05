# Handles one_lambda_per_controller
class Jets::Cfn::Resource::Lambda::Function
  class Controller < Jets::Cfn::Resource::Lambda::Function
    # override
    def combined_properties
      props = env_properties
        .deep_merge(global_properties)
        .deep_merge(class_properties)
        # .deep_merge(function_properties) # comment left to emphasize controller cannot have function_properties
      finalize_properties!(props)
    end

    # override
    def permission
      Jets::Cfn::Resource::Lambda::Permission.new(replacements, self,
        Principal: "apigateway.amazonaws.com",
        SourceArn: "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*",
      )
    end
  end
end
