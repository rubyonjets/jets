module Jets::Stack::Main::Dsl
  module Sqs
    def sqs_queue(id, props={})
      # props[:queue_name] ||= id.to_s # comment out to allow CloudFormation to generate name
      resource(id, "AWS::SQS::Queue", props)
      # output(id) # normal !Ref returns the sqs url the ARN is more useful
      output(id, getatt(id, :arn))
    end
  end
end