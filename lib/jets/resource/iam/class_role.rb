module Jets::Resource::Iam
  class ClassRole < Jets::Resource::Base
    def initialize(app_class)
      @app_class = app_class.to_s # IE: PostsController, HardJob, Hello, HelloFunction
      @policy_definitions = app_class.class_iam_policy || [] # class_iam_policy contains policy definitions
    end

    def definition
      {
        "{namespace}IamPolicy" => {
          type: "AWS::IAM::Policy",
          properties: {
            policy_name: "{namespace}Policy",
            policy_document: policy_document,
          }
        }
      }
    end

    def replacements
      {
        namespace: @app_class.camelize,
      }
    end

    def policy_document
      PolicyDocument.new(@policy_definitions).policy_document
    end
  end
end