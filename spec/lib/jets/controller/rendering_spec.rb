require "spec_helper"

describe Jets::Controller::Base do
  let(:controller) { RenderMeController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "general" do
    let(:event) { nil }
    it "render :new" do
      resp = controller.render(:new)
      expect(resp).to eq("new html")
    end

    it "layout set to application" do
      expect(controller.class.layout).to eq "application"
    end
  end

end
