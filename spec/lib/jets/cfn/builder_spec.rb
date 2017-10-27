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
      puts cfn.text
      IO.write("tmp/template.yml", cfn.text)
    end
  end
end
