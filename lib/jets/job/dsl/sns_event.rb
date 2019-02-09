module Jets::Job::Dsl
  module SnsEvent
    def sns_event(topic_name, props={})
      if topic_name.to_s =~ /generate/
        declare_sns_topic(props.delete(:topic_properties))
        topic_arn = "!Ref {namespace}SnsTopic"
        props.merge!(topic_arn: topic_arn)
        declare_sns_subscription(props)
      elsif topic_name.include?('!Ref') # reference shared resource
        topic_arn = topic_name # contains !Ref
        props.merge!(topic_arn: topic_arn)
        declare_sns_subscription(props)
      else # existing topic: short name or full arn
        topic_arn = full_sns_topic_arn(topic_name)
        props.merge!(topic_arn: topic_arn)
        declare_sns_subscription(props)
      end
    end

    def declare_sns_topic(props={})
      props ||= {} # props.delete(:topic_properties) can be nil
      r = Jets::Resource::Sns::Topic.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end

    def declare_sns_topic_policy(props={})
      props ||= {} # options.delete(:topic_policy_properties) can be nil
      r = Jets::Resource::Sns::TopicPolicy.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end

    def declare_sns_subscription(props={})
      r = Jets::Resource::Sns::Subscription.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end

    # Expands simple topic name to full arn. Example:
    #
    #   hello-topic
    # To:
    #   arn:aws:sns:us-west-2:112233445566:hello-topic
    def full_sns_topic_arn(topic_name)
      return topic_name if topic_name.include?("arn:aws:sns")

      "arn:aws:sns:#{Jets.aws.region}:#{Jets.aws.account}:#{topic_name}"
    end
  end
end
