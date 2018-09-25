module Jets::Stack::Main::Dsl
  module Sqs
    def sqs_queue(id, props={})
      resource(id, "AWS::SNS::Topic", props)
      output(id)
    end
  end
end