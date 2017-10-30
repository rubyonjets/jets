require "spec_helper"

describe Jets::Naming do
  let(:names) do
    Jets::Naming.new(PostsController, :create)
  end

  describe "Naming" do
    it "creates names appropriate for CloudFormation" do
      expect(names.handler).to eq "handlers/controllers/posts.create"
      expect(names.logical_id).to eq "PostsControllerCreate"
      expect(names.function_name).to eq "proj-dev-posts-controller-create"
      expect(names.s3_key).to include("jets/cfn-templates")
    end
  end
end
