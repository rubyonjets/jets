module Jets::Job::Dsl
  module IotEvent
    # The user must at least pass in an SQL statement
    def iot_event(props={})
      if props.is_a?(String) # SQL Statement
        props = {sql: props}
        topic_props = {topic_rule_payload: props}
      elsif props.key?(:topic_rule_payload) # full properties structure
        topic_props = props
      else # just the topic_rule_payload
        topic_props = {topic_rule_payload: props}
      end

      declare_iot_topic(topic_props)
    end

    def declare_iot_topic(props={})
      r = Jets::Resource::Iot::TopicRule.new(props)
      with_fresh_properties do
        resource(r.definition) # add associated resource immediately
      end
    end
  end
end
