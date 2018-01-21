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


class RedirectionController < Jets::Controller::Base
end

describe RedirectionController do
  let(:controller) { RedirectionController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }
  context "redirect from localhost" do
    let(:event) do
      {
        "headers" => {
          "origin" => "http://localhost:8888",
        },
      }
    end
    it "redirect_to" do
      resp = controller.send(:redirect_to, "/myurl", status: 301)
      redirect_url = resp["headers"]["Location"]
      expect(redirect_url).to eq "http://localhost:8888/myurl"
    end
  end

  context "redirect from amazonaws.com with origin set" do
    let(:event) do
      {
        "headers" => {
          "origin" => "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com",
        },
      }
    end
    it "redirect_to adds the stage name to the url" do
      resp = controller.send(:redirect_to, "/myurl", status: 301)
      redirect_url = resp["headers"]["Location"]
      expect(redirect_url).to eq "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com/test/myurl"
    end
  end

  context "redirect from amazonaws.com with Origin set" do
    let(:event) do
      {
        "headers" => {
          "Origin" => "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com",
        },
      }
    end
    it "redirect_to adds the stage name to the url" do
      resp = controller.send(:redirect_to, "/myurl", status: 301)
      redirect_url = resp["headers"]["Location"]
      expect(redirect_url).to eq "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com/test/myurl"
    end
  end
end
