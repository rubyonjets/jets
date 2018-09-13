module Jets::Stack::Main::Dsl
  module Sns
    def sns_topic(id, props={})
      resource(id, "AWS::SNS::Topic",
        properties: props
      )
      output(id)
    end
  end
end