require_relative "../../../spec_helper"

describe Jets::Cfn::Builder do
  let(:cfn) do
    Jets::Cfn::Builder.new(PostsController)
  end

  describe "Cfn::Builder" do
    it "adds functions to resources" do
      cfn.compose!
      expect(cfn.template[:Resources].keys).to eq(
        ["PostsControllerCreate", "PostsControllerUpdate"]
      )
      file_exist = File.exist?("/tmp/jets_build/templates/posts-controller.yml")
      expect(file_exist).to be true
    end
  end
end
