class Jets::Rule::AwsManagedRule < Jets::Rule::Task
  def config_rule_defaults
    {
      "ConfigRuleName" => config_rule_name,
      "Source" => {
        "Owner" => "AWS",
        "SourceIdentifier" => "INCOMING_SSH_DISABLED"
      }
    }
  end
end
