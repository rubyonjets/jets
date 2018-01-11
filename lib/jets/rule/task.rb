class Jets::Rule::Task < Jets::Lambda::Task
  attr_reader :config_rule
  def initialize(class_name, meth, options={})
    super
    @config_rule = options[:config_rule] || {}
  end

  def config_rule_name
    @properties[:config_rule_name] || conventional_config_rule_name
  end

  def conventional_config_rule_name
    name_without_rule = @class_name.underscore.gsub(/_rule$/,'')
    "#{name_without_rule}_#{@meth}".dasherize
  end

  def config_rule_properties
    props = Pascalize.pascalize(@config_rule)
    props = config_rule_defaults.merge(props)
    props
  end

  def config_rule_defaults
    map = Jets::Cfn::TemplateMappers::ConfigRuleMapper.new(self)
    source_identifier = "!GetAtt #{map.lambda_function_logical_id}.Arn"
    {
      "ConfigRuleName" => config_rule_name,
      "Source" => {
        "Owner" => "CUSTOM_LAMBDA",
        "SourceIdentifier" => source_identifier,
        "SourceDetails" => [
            {
                "EventSource" => "aws.config",
                "MessageType" => "ConfigurationItemChangeNotification"
            },
            {
                "EventSource" => "aws.config",
                "MessageType" => "OversizedConfigurationItemChangeNotification"
            }
        ]
      }
    }
  end
end
