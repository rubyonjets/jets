module Jets::Resource::Iam
  class ApplicationRole < Jets::Resource::Base
    def initialize
      @policy_definitions = Jets.config.iam_policy # config.iam_policy contains definitions
      @policy_definitions = [@policy_definitions].flatten if @policy_definitions
    end

    def definition
      {
        "IamRole" => {
          type: "AWS::IAM::Role",
          properties: {
            policy_name: "ApplicationRole",
            policy_document: policy_document,
          }
        }
      }
    end

    def policy_document
      PolicyDocument.new(@policy_definitions).policy_document
    end
  end
end