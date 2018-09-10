module Jets::Resource::Config
  class ConfigRule < Jets::Resource::Base
    def initialize(props)
      @props = props # from dsl.rb
    end

    def definition
      {
        config_rule_logical_id => {
          type: "AWS::Config::ConfigRule",
          properties: definition_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def definition_properties
      {
        config_rule_name: "{config_rule_name}",
        source: {
          owner: "CUSTOM_LAMBDA",
          source_identifier: "!GetAtt {namespace}LambdaFunction.Arn",
          source_details: [
            {
              event_source: "aws.config",
              message_type: "ConfigurationItemChangeNotification"
            },
            {
              event_source: "aws.config",
              message_type: "OversizedConfigurationItemChangeNotification"
            }
          ]
        }
      }.merge(@props)
    end

    def config_rule_logical_id
      "{namespace}_config_rule"
    end
  end
end