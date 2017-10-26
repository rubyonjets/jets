require_relative "../../../spec_helper"

describe Jets::Cfn::Namer do
  let(:namer) do
    Jets::Cfn::Namer.new(CommentsController, :create)
  end

  describe "Cfn::Namer" do
    it "creates names appropriate for CloudFormation" do
      expect(namer.handler).to eq "handlers/controllers/comments.create"
      expect(namer.logical_id).to eq "CommentsControllerCreate"
      expect(namer.function_name).to eq "proj-dev-comments-controller-create"
      expect(namer.s3_key).to include("jets/cfn-templates/dev/")
    end
  end
end
