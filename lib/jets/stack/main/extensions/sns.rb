module Jets::Stack::Main::Dsl
  module Sns
    def sns_topic(id, props={})
      resource(id, "AWS::SNS::Topic", props)
      output(id) # Topic Arn
    end

    def sns_topic_policy(id, props={})
      resource(id, "AWS::SNS::TopicPolicy", props)
    end

    def sns_subscription(id, props={})
      resource(id, "AWS::SNS::Subscription", props)
    end
  end
end