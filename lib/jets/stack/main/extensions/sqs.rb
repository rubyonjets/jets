module Jets::Stack::Main::Dsl
  module Sqs
    def sqs_queue(id, props={})
      id = logical_id(id)
      resource(id, "AWS::SQS::Queue", props)
      output(id)
    end

    def sqs_lambda_trigger(id, props={})
      id = logical_id(id)
      resource(id, "AWS::Lambda::EventSourceMapping", props)
      output(id)
    end

    def sqs_queue_with_lambda_trigger(id, props={})
      id = logical_id(id)
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

      # Setup properties for each resource
      dlq = queue_props(:dlq, defaults, props)
      queue = queue_props(:queue, defaults, props)
      lambda = queue_props(:lambda, defaults, props)

      sqs_queue("#{id}DeadLetterQueue", dlq)
      sqs_queue("#{id}Queue", queue)
      sqs_lambda_trigger("#{id}LambdaTrigger", lambda)

      [output("#{id}DeadLetterQueue"), output("#{id}Queue"), output("#{id}LambdaTrigger")]
    end

  private
    # name - :dlq, :queue, or :lambda - resource name as a symbol
    def queue_props(name, defaults, props)
      if name == :lambda
        props[:lambda][:function_name] = "!Ref #{logical_id(props[:lambda][:function_name])}"
      end

      defaults[name].deep_merge(props.fetch(name, {}))
    end
  end
end