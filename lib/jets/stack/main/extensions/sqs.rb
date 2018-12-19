module Jets::Stack::Main::Dsl
  module Sqs
    def sqs_queue(id, props={})
      resource(id, "AWS::SQS::Queue", props)
      output(id)
    end
    def sqs_lambda_trigger(id, props={})
      resource(id, "AWS::Lambda::EventSourceMapping", props)
      output(id)
    end
    def sqs_queue_with_lambda_trigger(id, props={})
      defaults = {
        dlq: {
          queue_name: "#{id}-DLQ"
        },
        queue: {
          queue_name: "#{id}",
          redrive_policy: {
              dead_letter_target_arn: "!GetAtt #{id}DeadLetterQueue.Arn",
          },
          visibility_timeout: 900
        },
        lambda: {
          batch_size: 10,
          enabled: true,
          event_source_arn: "!GetAtt #{id}Queue.Arn",
        }
      }

      sqs_queue("#{id}DeadLetterQueue", defaults[:dlq].deep_merge(props.fetch(:dlq, {})))
      sqs_queue("#{id}Queue", defaults[:queue].deep_merge(props.fetch(:queue, {})))
      sqs_lambda_trigger("#{id}LambdaTrigger", defaults[:lambda].deep_merge(props.fetch(:lambda, {})))
      [output("#{id}DeadLetterQueue"), output("#{id}Queue"), output("#{id}LambdaTrigger")]
    end    
  end
end