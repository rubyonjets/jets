require "spec_helper"

describe Jets::Controller::Base do
  let(:controller) { StoresController.new({}, nil, "index") }

  context "method" do
    it "render :new" do
      resp = controller.render(:new)
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    # should work also
    # it "render new" do
    #   resp = controller.render("new")
    #   pp resp
    #   # expect(resp).to eq("new html")
    # end

    it "render stores/new" do
      resp = controller.render("stores/new")
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render template: store/new" do
      resp = controller.render(template: "stores/new")
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render json" do
      resp = controller.render(json: {my: "data"})
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render file" do
      resp = controller.render(file: "public/assets/a.txt")
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render plain" do
      resp = controller.render(plain: "text")
      expect(resp).to eq "text" # TODO: think is wrong because it is not
        # the AWS proxy format
      # expect(resp["body"]).to be_a(String)
    end

  end
end
