module Jets::Cfn::Resource::Events
  class Rule < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        rule_logical_id => {
          Type: "AWS::Events::Rule",
          Properties: merged_properties
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      {
        State: "ENABLED",
        Targets: [{
          Arn: "!GetAtt {namespace}LambdaFunction.Arn",
          Id: "{namespace}RuleTarget"
        }]
      }.deep_merge(@props)
    end

    def rule_logical_id
      "{namespace}EventsRule"
    end
  end
end