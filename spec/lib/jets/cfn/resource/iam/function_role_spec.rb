describe Jets::Cfn::Resource::Iam::FunctionRole do
  let(:role) do
    Jets::Cfn::Resource::Iam::FunctionRole.new(task)
  end
  let(:task) do
    PostsController.all_public_definitions[:new]
  end

  context "iam policy" do
    it "inherits from the application and class wide iam policy" do
      # Since one_lambda_for_all_controllers is default this IAM policy is empty
      # because the Lambda function points to the main ApplicationController IAM policy
      expect(role.policy_document).to eq(
        {:Version=>"2012-10-17", :Statement=>[]}
      )
    end
  end
end