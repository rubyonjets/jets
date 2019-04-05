module Jets::Stack::Main::Dsl
  module Iam
    def iam_role(id, props={})
      resource(id, "AWS::IAM::Role", props)
      output(id) # IAM Arn
    end
  end
end
