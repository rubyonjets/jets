module Jets::Resource::ApiGateway::BasePath
  class Role < Jets::Resource::Base
    extend Memoist
    include Jets::AwsServices

    def definition
      {
        base_path_role: {
          type: "AWS::IAM::Role",
          properties: {
            role_name: role_name,
            path: "/",
            assume_role_policy_document: {
              version: "2012-10-17",
              statement: [{
                effect: "Allow",
                principal: {service: ["lambda.amazonaws.com"]},
                action: ["sts:AssumeRole"]}
              ]
            },
            policies: [
              policy_name: "#{role_name}-policy",
              policy_document: policy_document,
            ]
          },
        }
      }
    end

    def policy_document
      project_namespace = Jets.config.project_namespace
      default_policy_statements = Jets::Application.default_iam_policy # Array of Hashes
      apigateway = [{
        action: [ "apigateway:*" ],
        effect: "Allow",
        resource: "arn:aws:apigateway:#{Jets.aws.region}::/restapis/*", # scoped to all restapis because this changes
      },{
        action: [ "apigateway:*" ],
        effect: "Allow",
        resource: "arn:aws:apigateway:#{Jets.aws.region}::/domainnames/*", # scoped to all restapis because this changes
      }]
      cloudformation = [{
        action: ["cloudformation:DescribeStacks"],
        effect: "Allow",
        resource: "arn:aws:cloudformation:#{Jets.aws.region}:#{Jets.aws.account}:stack/#{project_namespace}*",
      }]

      # Combine the statements
      {
        version: '2012-10-17',
        statement: default_policy_statements + apigateway + cloudformation
      }
    end

    # Duplicated in rest_api/change_detection.rb, base_path/role.rb, rest_api/routes.rb
    def rest_api_id
      stack_name = Jets::Naming.parent_stack_name
      return "RestApi" unless stack_exists?(stack_name)

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")

      # resources = cfn.describe_stack_resources(stack_name: api_gateway_stack_arn).stack_resources
      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api_id = lookup(stack[:outputs], "RestApi")
    end
    memoize :rest_api_id

    def role_name
      # TODO: dont think we should change the role name every time but have to right now because the deployment logical id changes
      timestamp = Jets::Resource::ApiGateway::Deployment.timestamp
      "#{Jets.config.project_namespace}-base-path-mapping-#{timestamp}"
    end
  end
end
