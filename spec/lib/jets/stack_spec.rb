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
  # ...
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
    # pp stack.outputs
    expect(stack.outputs).to eq(
      [[{:vpc_id=>{:description=>"vpc id", :value=>"!Ref vpc"}}],
       [:stack_name, {:value=>"!Ref AWS::StackName"}],
       [:elb, {:value=>"!Ref Elb"}],
       [:elb]]
    )
  end
end
