class ExampleStack < Jets::Stack
  # long form
  parameter(instance_type: {
    default: "t2.micro" ,
    description: "instance type" ,
  })
  # medium form
  parameter :company, default: "boltops"
  # short form
  parameter :ami_id, "ami-123"
end

describe "Stack" do
  let(:stack) { ExampleStack.new }
  it "param" do
    pp stack.parameters
  end
end
