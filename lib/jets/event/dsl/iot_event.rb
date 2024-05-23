module Jets::Event::Dsl
  module IotEvent
    # The user must at least pass in an SQL statement
    # Returns topic_props
    # interface method
    def iot_event(props = {})
      if props.is_a?(String) # SQL Statement
        props = {Sql: props}
        {TopicRulePayload: props}
      elsif props.key?(:TopicRulePayload) # full properties structure
        props
      else # just the TopicRulePayload
        {TopicRulePayload: props}
      end
    end
  end
end
