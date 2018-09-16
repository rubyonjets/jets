class ExampleStack2 < Jets::Stack
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
  output :elb2 # short form

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

class ExampleCustom < Jets::Stack
  resource(:hello,
    type: "AWS::Lambda::Function",
    properties: {
      function_name: "hello",
      code: {
        s3_bucket: "!Ref S3Bucket",
        s3_key: code_s3_key
      },
      description: "Hello world",
      handler: handler("hello.lambda_handler"),
      memory_size: 128,
      role: "!Ref IamRole",
      runtime: "python3.6",
      timeout: 20,
    }
  )
end

# SecurityJob:
#   Type: AWS::CloudFormation::Stack
#   Properties:
#     TemplateURL: https://s3.amazonaws.com//jets/cfn-templates/config-dev-security_job.yml
#     Parameters:
#       IamRole: !GetAtt IamRole.Arn
#       S3Bucket: !Ref S3Bucket

# # Belongs in parent_builder_spec.rb
# Alarm:
#   Type: AWS::CloudFormation::Stack
#   Properties:
#     TemplateURL: https://s3.amazonaws.com//jets/cfn-templates/config-dev-shared-custom.yml
#     Parameters:
#       Alert: !Ref Alert
#   DependsOn:
#   - Alert
# Alert:
#   Type: AWS::CloudFormation::Stack
#   Properties:
#     TemplateURL: https://s3.amazonaws.com//jets/cfn-templates/config-dev-shared-custom.yml
#   Epen

describe "Stack templates" do
  let(:stack) { ExampleStack2.new }
  it "parameters" do
    templates = stack.parameters.map(&:template)
    expect(templates).to eq(
      [{"InstanceType"=>
         {"Default"=>"t2.micro", "Description"=>"instance type", "Type"=>"String"}},
       {"Company"=>{"Default"=>"boltops", "Type"=>"String"}},
       {"AmiId"=>{"Default"=>"ami-123", "Type"=>"String"}}]
    )
  end

  it "outputs" do
    templates = stack.outputs.map(&:template)
    expect(templates).to eq(
      [{"VpcId"=>{"Description"=>"vpc id", "Value"=>"!Ref vpc_id"}},
      {"StackName"=>{"Value"=>"!Ref AWS::StackName"}},
      {"Elb"=>{"Value"=>"!Ref Elb"}},
      {"Elb2"=>{"Value"=>"!Ref Elb2"}}]
    )
  end

  it "resources" do
    templates = stack.resources.map(&:template)
    expect(templates).to eq(
      [{"SnsTopic"=>
        {"Type"=>"AWS::SNS::Topic",
          "Properties"=>{"Description"=>"my desc", "DisplayName"=>"my name"}}},
      {"SnsTopic2"=>
        {"Type"=>"AWS::SNS::Topic", "Properties"=>{"DisplayName"=>"my name 2"}}},
      {"SnsTopic3"=>
        {"Type"=>"AWS::SNS::Topic", "Properties"=>{"DisplayName"=>"my name 3"}}}]
    )
  end

  context "depends_on" do
    it "works" do
      expect(ExampleAlarm.depends_on).to eq [:alert]
      expect(ExampleAlert.depends_on).to be nil
    end
  end

  context "functions" do
    it "selects function resources only" do
      expect(ExampleCustom.functions.size).to eq 1
      expect(ExampleAlarm.functions.size).to eq 0
      expect(ExampleAlert.functions.size).to eq 0
      expect(Custom.functions.size).to eq 4
    end
  end
end
