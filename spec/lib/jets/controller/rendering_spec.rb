require "spec_helper"

describe Jets::Controller::Base do
  let(:controller) {
    controller = StoresController.new({}, nil, "new")
    controller.new
    controller
  }

  context "render called" do
    it "render :new" do
      resp = controller.render(:new)
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render new" do
      resp = controller.render("new")
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

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
      resp = controller.render(file: "#{Jets.root}public/assets/a.txt")
      # pp resp
      expect(resp["body"]).to be_a(String)
    end

    it "render plain" do
      resp = controller.render(plain: "text")
      # pp resp
      expect(resp["body"]).to be_a(String)
      expect(resp["headers"]["Content-Type"]).to eq "text/html; charset=utf-8"
    end

    it "render status: 404" do
      resp = controller.render(status: 404)
      # pp resp
      expect(resp["statusCode"]).to eq 404
    end
  end

  context "ensure_render implicitly called due to no previous rendering" do
    it "ensure_render" do
      controller = StoresController.new({}, nil, "new")
      controller.new
      resp = controller.ensure_render
      # pp resp
      expect(resp["body"]).to be_a(String)
    end
  end
end
