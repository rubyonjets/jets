require_relative "../../../spec_helper"

describe Jets::Cfn::Bake do
  let(:bake) do
    Jets::Cfn::Bake.new(noop: true)
  end

  describe "Cfn::Bake" do
    it "adds functions to resources" do
      expect(bake).to receive(:wait_for_stack) # stub
      bake.run
    end
  end
end
