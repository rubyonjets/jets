describe Jets::Cfn::TemplateBuilders::ManagedIamPolicy::FunctionPolicy do
  # mainly mocks out iam_policy.definitions
  let(:iam_policy) do
    task = double(:task).as_null_object
    iam_policy = Jets::Cfn::TemplateBuilders::ManagedIamPolicy::FunctionPolicy.new(task)
    allow(iam_policy).to receive(:definitions).and_return(definitions)
    iam_policy
  end

  context "single string" do
    let(:definitions) { ["AmazonEC2ReadOnlyAccess"] }
    it "provides the iam managed policy arn" do
      expect(iam_policy.arns).to eq ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
    end
  end

  context "multiple strings" do
    let(:definitions) { ["AmazonEC2ReadOnlyAccess", "service-role/AWSConfigRulesExecutionRole"] }
    it "provides the iam managed policy arn" do
      expect(iam_policy.arns).to eq [
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole",
      ]
    end
  end

  context "full arn provided" do
    let(:definitions) { ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"] }
    it "provides the iam managed policy arn" do
      expect(iam_policy.arns).to eq [
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
      ]
    end
  end
end
