module Jets::Job::Dsl
  module IotEvent
    # The user must at least pass in an SQL statement
    def iot_event(props={})
      if props.is_a?(String) # SQL Statement
        props = {Sql: props}
        topic_props = {TopicRulePayload: props}
      elsif props.key?(:TopicRulePayload) # full properties structure
        topic_props = props
      else # just the TopicRulePayload
        topic_props = {TopicRulePayload: props}
      end

      declare_iot_topic(topic_props)
    end

    def declare_iot_topic(props={})
      r = Jets::Cfn::Resource::Iot::TopicRule.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end
  end
end
