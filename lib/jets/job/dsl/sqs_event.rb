# ## Event Source Mapping
#
# Underneath the hood, the `sqs_event` method sets up a  [Lambda::EventSourceMapping](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html).  So:
#
# ```ruby
# class HardJob
#   class_timeout 30 # must be less than or equal to the SQS queue default timeout
#
#   sqs_event "hello-queue"
#   def dig
#     puts "dig event #{JSON.dump(event)}"
#   end
# end
# ```
#
# Cloud also be written with something like this:
#
# ```ruby
# class HardJob
#   class_timeout 30 # must be less than or equal to the SQS queue default timeout
#
#   event_source_mapping(
#     event_source_arn: "arn:aws:sqs:us-west-2:112233445566:hello-queue",
#   )
#   iam_policy(
#     action: ["sqs:ReceiveMessage",
#             "sqs:DeleteMessage",
#             "sqs:GetQueueAttributes"],
#     effect: "Allow",
#     resource: "arn:aws:sqs:us-west-2:112233445566:hello-queue",
#   )
#   def dig
#     puts "dig event #{JSON.dump(event)}"
#   end
# end
# ```
#
module Jets::Job::Dsl
  module SqsEvent
    def sqs_event(queue_name, options={})
      if queue_name.to_s =~ /generate/
        queue_arn = "!GetAtt {namespace}SqsQueue.Arn"
        default_iam_policy = default_sqs_iam_policy('*') # Dont have access to full ARN on initial creation
        declare_sqs_queue(options.delete(:queue_properties)) # delete to avoid using them for event_source_mapping
      elsif queue_name.include?('!Ref') # reference shared resource
        queue_arn = queue_name
        default_iam_policy = default_sqs_iam_policy('*') # Dont have access to full ARN on initial creation
      else # existing queue: short name or full arn
        queue_arn = full_sqs_queue_arn(queue_name)
        default_iam_policy = default_sqs_iam_policy(queue_arn)
      end

      # Create iam policy allows access to queue
      # Allow disabling in case use wants to add permission application-wide and not have extra IAM policy
      iam_policy_props = options.delete(:iam_policy) || @iam_policy || default_iam_policy
      iam_policy(iam_policy_props) unless iam_policy_props == :disable

      props = options # by this time options only has EventSourceMapping properties
      default = {
        event_source_arn: queue_arn
      }
      props = default.merge(props)

      event_source_mapping(props)
    end

    def declare_sqs_queue(props)
      props ||= {} # since options.delete(:queue_properties) can be nil
      r = Jets::Resource::Sqs::Queue.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end

    # Expands simple queue name to full arn. Example:
    #
    #   hello-queue
    # To:
    #   arn:aws:sqs:us-west-2:112233445566:hello-queue
    def full_sqs_queue_arn(queue_name)
      return queue_name if queue_name.include?("arn:aws:sqs")

      "arn:aws:sqs:#{Jets.aws.region}:#{Jets.aws.account}:#{queue_name}"
    end

    def default_sqs_iam_policy(queue_name_arn='*')
      {
        action: ["sqs:ReceiveMessage",
                 "sqs:DeleteMessage",
                 "sqs:GetQueueAttributes"],
        effect: "Allow",
        resource: queue_name_arn,
      }
    end
  end
end