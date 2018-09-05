module Jets::Resource::Iam
  class FunctionRole < Jets::Resource::Base
    def initialize(task)
      @task = task
      @policy_definitions = task.iam_policy || [] # iam_policy contains policy definitions
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
        namespace: "#{@task.class_name}#{@task.meth.to_s.camelize}",
      }
    end

    def policy_document
      PolicyDocument.new(@policy_definitions).policy_document
    end
  end
end