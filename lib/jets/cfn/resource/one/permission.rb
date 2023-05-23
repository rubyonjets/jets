module Jets::Cfn::Resource::One
  class Permission < Jets::Cfn::Base
    def definition
      {
        JetsControllerPermission: {
          Type: "AWS::Lambda::Permission",
          Properties: {
            FunctionName: "!Ref JetsControllerLambdaFunction",
            Action: "lambda:InvokeFunction",
            Principal: "apigateway.amazonaws.com",
            SourceArn: "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*",
          }
        }
      }
    end
  end
end
