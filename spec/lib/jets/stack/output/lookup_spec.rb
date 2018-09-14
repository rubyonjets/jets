require 'recursive-open-struct'

class Alert < Jets::Stack
  # the definition doesnt matters because it's no used in the spec but added for clarity
  sns.topic(:my_sns_topic, display_name: "cool topic")
end

describe "shared resource" do
  let(:shared_resource_class) do
    allow(Alert).to receive(:cfn).and_return(cfn)
    Alert
  end
  let(:cfn) do
    cfn = double(:cfn)
    allow(cfn).to receive(:describe_stacks).with(stack_name: "demo-test").and_return(parent_response)
    allow(cfn).to receive(:describe_stacks).with(stack_name: shared_stack_arn).and_return(child_response)
    cfn
  end
  let(:parent_response) do
    RecursiveOpenStruct.new({
      stacks: [
        outputs: [{
          output_key: "S3Bucket",
          output_value: "demo-test-s3bucket-1evq5kzp1an0m",
        },{
          output_key: "Alert",
          output_value: shared_stack_arn,
        }]
      ]
    }, recurse_over_arrays: true)
  end
  let(:child_response) do
    RecursiveOpenStruct.new({
      stacks: [
        outputs: [{
          output_key: "MySnsTopic",
          output_value: sns_child_arn,
        }]
      ]
    }, recurse_over_arrays: true)
  end

  let(:shared_stack_arn) do
    'arn:aws:cloudformation:us-west-2:111111111111:stack/demo-test-Alert-TBJ19S6JPXPD/e8d1ec20-b5c0-11e8-a781-503ac9ec2461'
  end
  let(:sns_child_arn) do
    "arn:aws:sns:us-west-2:111111111111:config-dev-Alert-TBJ19S6JPXPD-MySnsTopic-3EW5BWDH5L1Z"
  end

  it "output" do
    arn = shared_resource_class.arn("my_sns_topic")
    expect(arn).to eq sns_child_arn
  end

  it "shared_stack_arn" do
    arn = shared_resource_class.shared_stack_arn
    expect(arn).to eq shared_stack_arn
  end
end