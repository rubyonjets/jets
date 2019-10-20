module Jets::Stack::Main::Dsl
  module Sqs
    def sqs_queue(id, props={})
      # props[:queue_name] ||= id.to_s # comment out to allow CloudFormation to generate name
      resource(id, "AWS::SQS::Queue", props)
      output(id, value: get_att("#{id}.Arn")) # normal !Ref returns the sqs url the ARN is useful for nested stacks depends_on
      output("#{id}_url", ref(id)) # useful for Stack.lookup method. IE: List.lookup(:waitlist_url)
    end
  end
end
