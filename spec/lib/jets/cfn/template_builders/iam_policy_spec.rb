describe Jets::Cfn::TemplateBuilders::IamPolicy do
  let(:iam_policy) do
    Jets::Cfn::TemplateBuilders::IamPolicy.new(iam_policies)
  end

  context "single string" do
    let(:iam_policies) { ["ec2:*"] }
    it "provides the resource definition" do
      iam_policy_json = <<-JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON
      expected_policy = JSON.load(iam_policy_json)
      expect(iam_policy.resource).to eq expected_policy
    end
  end

  context "multiple strings" do
    let(:iam_policies) { ["ec2:*", "logs:*"] }
    it "provides the resource definition" do
      iam_policy_json = <<-JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "Stmt2",
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON
      expected_policy = JSON.load(iam_policy_json)
      expect(iam_policy.resource).to eq expected_policy
    end
  end
end
