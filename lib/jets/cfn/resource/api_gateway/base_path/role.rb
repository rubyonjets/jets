module Jets::Cfn::Resource::ApiGateway::BasePath
  class Role < Jets::Cfn::Base
    extend Memoist
    include Jets::AwsServices

    def definition
      {
        BasePathRole: {
          Type: "AWS::IAM::Role",
          Properties: {
            # RoleName: role_name,
            Path: "/",
            AssumeRolePolicyDocument: {
              Version: "2012-10-17",
              Statement: [{
                Effect: "Allow",
                Principal: {Service: ["lambda.amazonaws.com"]},
                Action: ["sts:AssumeRole"]}
              ]
            },
            Policies: [
              PolicyName: "base-path-mapping-policy", # cannot be empty
              PolicyDocument: policy_document,
            ]
          },
        }
      }
    end

    def policy_document
      project_namespace = Jets.project_namespace
      default_policy_statements = Jets.application.config.default_iam_policy # Array of Hashes
      apigateway = [{
        Action: [ "apigateway:*" ],
        Effect: "Allow",
        Resource: "arn:aws:apigateway:#{Jets.aws.region}::/restapis/*", # scoped to all restapis because this changes
      },{
        Action: [ "apigateway:*" ],
        Effect: "Allow",
        Resource: "arn:aws:apigateway:#{Jets.aws.region}::/domainnames/*", # scoped to all restapis because this changes
      }]
      cloudformation = [{
        Action: ["cloudformation:DescribeStacks"],
        Effect: "Allow",
        Resource: "arn:aws:cloudformation:#{Jets.aws.region}:#{Jets.aws.account}:stack/#{project_namespace}*",
      }]

      # Combine the statements
      {
        Version: '2012-10-17',
        Statement: default_policy_statements + apigateway + cloudformation
      }
    end

    # Duplicated in rest_api/change_detection.rb, base_path/role.rb, rest_api/routes.rb
    def rest_api_id
      stack_name = Jets::Names.parent_stack_name
      return "RestApi" unless stack_exists?(stack_name)

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")

      # resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api_id = lookup(stack[:outputs], "RestApi")
    end
    memoize :rest_api_id
  end
end
