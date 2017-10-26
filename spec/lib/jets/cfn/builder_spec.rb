require_relative "../../../spec_helper"

describe Jets::Cfn::Builder do
  let(:cfn) do
    Jets::Cfn::Builder.new(CommentsController)
  end

  describe "Cfn::Builder" do
    it "adds functions to resources" do
      cfn.compose!
      expect(cfn.template[:Resources].keys).to eq(
        ["CommentsControllerCreate", "CommentsControllerUpdate"]
      )
      puts cfn.text
    end
  end
end
