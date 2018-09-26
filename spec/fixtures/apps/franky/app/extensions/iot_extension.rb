module IotExtension
  def thermostat_rule(logical_id, props={})
    logical_id = "#{logical_id}_topic_rule"
    defaults = {
      topic_rule_payload: {
        sql: "select * from TemperatureTopic where temperature > 60"
      },
      actions: [
        lambda: { function_arn: "!Ref {namespace}LambdaFunction" }
      ]
    }
    props = defaults.deep_merge(props)
    resource(logical_id, "AWS::Iot::TopicRule", props)
    # resource(
    #   logical_id => {
    #     type: "AWS::Iot::TopicRule",
    #     properites: props
    #   }
    # )
  end
end