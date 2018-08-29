describe Jets::Cfn::TemplateBuilders::ManagedIamPolicy::ApplicationPolicy do
  let(:iam_policy) do
    iam_policy = Jets::Cfn::TemplateBuilders::ManagedIamPolicy::ApplicationPolicy.new
    allow(iam_policy).to receive(:definitions).and_return(definitions)
    iam_policy
  end

  # Most of the specs around ManagedIamPolicy is in function_policy_spec.rb.
  # Writing a spec here as a sanity check.
  context "single string" do
    let(:definitions) { ["AmazonEC2ReadOnlyAccess"] }
    it "provides the iam managed policy arn" do
      expect(iam_policy.arns).to eq ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
    end
  end
end
