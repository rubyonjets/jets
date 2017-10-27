require_relative "../../../spec_helper"

describe Jets::Cfn::Deploy do
  let(:deploy) do
    Jets::Cfn::Deploy.new(noop: true).run
  end

  describe "Cfn::Deploy" do
    it "adds functions to resources" do
      deploy.run
    end
  end
end
