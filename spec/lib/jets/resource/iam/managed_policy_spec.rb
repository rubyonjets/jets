describe Jets::Resource::Iam::ManagedPolicy do
  let(:managed_policy) do
    Jets::Resource::Iam::ManagedPolicy.new(definitions)
  end

  context "single string" do
    let(:definitions) { "AmazonEC2ReadOnlyAccess" }
    it "builds the resource definition" do
      expect(managed_policy.arns).to eq ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
    end
  end
end