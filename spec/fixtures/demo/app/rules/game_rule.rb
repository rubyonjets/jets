class GameRule < Jets::Rule::Base
  # "ConfigRuleName" : String,
  # "Description" : String,
  # "InputParameters" : { ParameterName : Value },
  # "MaximumExecutionFrequency" : String,
  # "Scope" : Scope,
  # "Source" : Source

  # scope("ComplianceResourceTypes" => [ "AWS::EC2::SecurityGroup" ])

  # config_rule(
  #   config_rule_name: "String",
  #   description: "String",
  #   input_parameters: { "k1" => "v1" },
  #   maximum_execution_frequency: "String", # One_Hour | Three_Hours | Six_Hours | Twelve_Hours | TwentyFour_Hours # https://docs.aws.amazon.com/config/latest/APIReference/API_ConfigRule.html
  #   scope: {"ComplianceResourceTypes" => [ "AWS::EC2::SecurityGroup" ]},
  #   # source: # the method below here automatically is the source
  #   score: {
  #     "Owner" => "String", # CUSTOM_LAMBDA | AWS
  #   }
  # )
  scope "AWS::EC2::SecurityGroup"
  def protect
    puts "event #{event.inspect}"
  end
end
