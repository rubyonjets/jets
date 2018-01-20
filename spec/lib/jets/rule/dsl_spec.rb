require "spec_helper"

# Example with the full config_rule syntax
class FullPropertiesRule < Jets::Rule::Base
  config_rule(
    config_rule_name: "protect_rule_custom_name",
    description: "desc",
    input_parameters: { "k1" => "v1" },
    maximum_execution_frequency: "TwentyFour_Hours", # One_Hour | Three_Hours | Six_Hours | Twelve_Hours | TwentyFour_Hours # https://docs.aws.amazon.com/config/latest/APIReference/API_ConfigRule.html
    scope: { "ComplianceResourceTypes" => [ "AWS::EC2::SecurityGroup" ] },
    # source: # the method below here automatically is the source
    source: {
      "Owner" => "CUSTOM_LAMBDA",
      "SourceIdentifier" => "arn:aws:lambda:us-east-1:12345689012:function:rules-dev-test_properties_rule-protect",
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
  )
  def protect
    puts "protect"
  end
end

class PrettyPropertiesRule < Jets::Rule::Base
  scope "AWS::EC2::SecurityGroup"
  def protect
    puts "protect"
  end
end

describe Jets::Rule::Dsl do
  context "FullPropertiesRule" do
    let(:rule) { FullPropertiesRule.new({}, nil, "protect") }

    it "config_rule_properties" do
      protect_task = FullPropertiesRule.all_tasks[:protect]
      expect(protect_task).to be_a(Jets::Rule::Task)
      props = protect_task.config_rule_properties
      expect(props["ConfigRuleName"]).to eq "protect_rule_custom_name"
    end
  end

  context "PrettyPropertiesRule" do
    let(:rule) { PrettyPropertiesRule.new({}, nil, "protect") }

    it "scope expands to full ComplianceResourceTypes with AWS::EC2::SecurityGroup" do
      protect_task = PrettyPropertiesRule.all_tasks[:protect]
      expect(protect_task).to be_a(Jets::Rule::Task)
      props = protect_task.config_rule_properties
      expect(props["Scope"]["ComplianceResourceTypes"]).to eq(["AWS::EC2::SecurityGroup"])
    end
  end
end
