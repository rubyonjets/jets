describe Jets::Cfn::TemplateBuilders::IamPolicy::ClassPolicy do
  let(:iam_policy) do
    iam_policy = Jets::Cfn::TemplateBuilders::IamPolicy::ClassPolicy.new(PostsController)
    allow(iam_policy).to receive(:definitions).and_return(definitions)
    iam_policy
  end

  # Most of the specs around IamPolicy is in function_policy_spec.rb.
  # Writing a spec here as a sanity check.
  context "single string" do
    let(:definitions) { ["logs:*"] }
    it "provides the resource definition" do
      iam_policy_json = <<~EOL
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "Stmt1",
            "Action": [
              "logs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
          }
        ]
      }
      EOL
      expected_policy = JSON.load(iam_policy_json)
      expect(iam_policy.policy_document).to eq expected_policy
    end
  end
end
