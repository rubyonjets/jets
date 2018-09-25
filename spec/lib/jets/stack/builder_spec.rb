class ExampleStack < Jets::Stack
  ### Parameters
  # long form
  parameter(instance_type: {
    default: "t2.micro" ,
    description: "instance type" ,
  })
  # medium form
  parameter :company, default: "boltops"
  # short form
  parameter :ami_id, "ami-123"

  ### Outputs
  # long form
  output(vpc_id: {
    description: "vpc id",
    value: ref("vpc_id"),
  })
  # medium form
  output :stack_name, value: "!Ref AWS::StackName"
  # short form
  output :elb, "!Ref Elb"
  output :elb # short form

  ### Resources
  # long form
  resource(sns_topic: {
    type: "AWS::SNS::Topic",
    properties: {
      description: "my desc",
      display_name: "my name",
    }
  })
  # medium form
  resource(:sns_topic2,
    type: "AWS::SNS::Topic",
    properties: {
      display_name: "my name 2",
    }
  )
  # short form
  resource(:sns_topic3, "AWS::SNS::Topic",
    display_name: "my name 3",
  )
end

class ExampleAlarm < Jets::Stack
  depends_on :example_alert
end

class ExampleAlert < Jets::Stack
end

describe "Stack builder" do
  let(:builder) { Jets::Stack::Builder.new(stack) }

  context "full template" do
    let(:stack) { ExampleStack.new }

    it "template" do
      template = builder.template
      # puts YAML.dump(template) # uncomment to see and debug
      # Check just a few keys for sanity and keep spec at a reasonable length

      expect(template['Parameters']['InstanceType']['Default']).to eq 't2.micro'
      expect(template['Parameters']['Company']['Default']).to eq 'boltops'
      expect(template['Resources']['SnsTopic']['Type']).to eq 'AWS::SNS::Topic'
      expect(template['Resources']['SnsTopic2']['Type']).to eq 'AWS::SNS::Topic'
      expect(template['Outputs']['VpcId']['Description']).to eq 'vpc id'
      expect(template['Outputs']['StackName']['Value']).to eq '!Ref AWS::StackName'
    end
  end

  context "two stacks with depends_on" do
    let(:stack) { ExampleAlarm.new }

    it "adds parameters" do
      template = builder.template
      # puts YAML.dump(template) # uncomment to see and debug
      expect(template['Parameters']['ExampleAlert']['Type']).to eq 'String'
    end
  end
end
