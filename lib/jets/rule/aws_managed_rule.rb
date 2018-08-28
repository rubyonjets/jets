class Jets::Rule::AwsManagedRule < Jets::Rule::Task
  def config_rule_defaults
    source_identifier = meth.to_s.upcase
    {
      "ConfigRuleName" => config_rule_name,
      "Source" => {
        "Owner" => "AWS",
        "SourceIdentifier" => source_identifier
      }
    }
  end
end
