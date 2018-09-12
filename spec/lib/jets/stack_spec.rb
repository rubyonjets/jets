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
    value: ref("vpc"),
  })
  # medium form
  output :stack_name, value: "!Ref AWS::StackName"
  # short form
  output :elb, value: "!Ref Elb"
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
  resource(:sns_topic,
    type: "AWS::SNS::Topic",
    properties: {
      display_name: "my name",
    }
  )
  # short form
  resource(:sns_topic, "AWS::SNS::Topic",
    display_name: "my name",
  )
end

describe "Stack" do
  let(:stack) { ExampleStack.new }
  it "parameters" do
    expect(stack.parameters).to eq(
      [[{:instance_type=>{:default=>"t2.micro", :description=>"instance type"}}],
       [:company, {:default=>"boltops"}],
       [:ami_id, "ami-123"]]
    )
  end

  it "outputs" do
    expect(stack.outputs).to eq(
      [[{:vpc_id=>{:description=>"vpc id", :value=>"!Ref vpc"}}],
       [:stack_name, {:value=>"!Ref AWS::StackName"}],
       [:elb, {:value=>"!Ref Elb"}],
       [:elb]]
    )
  end

  it "resources" do
    expect(stack.resources).to eq(
      [[{:sns_topic=>
          {:type=>"AWS::SNS::Topic",
           :properties=>{:description=>"my desc", :display_name=>"my name"}}}],
       [:sns_topic,
        {:type=>"AWS::SNS::Topic", :properties=>{:display_name=>"my name"}}],
       [:sns_topic, "AWS::SNS::Topic", {:display_name=>"my name"}]]
    )
  end
end
