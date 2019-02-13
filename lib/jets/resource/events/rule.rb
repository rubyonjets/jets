module Jets::Resource::Events
  class Rule < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        rule_logical_id => {
          type: "AWS::Events::Rule",
          properties: merged_properties
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      {
        state: "ENABLED",
        targets: [{
          arn: "!GetAtt {namespace}LambdaFunction.Arn",
          id: "{namespace}RuleTarget"
        }]
      }.deep_merge(@props)
    end

    def rule_logical_id
      "{namespace}_events_rule"
    end
  end
end