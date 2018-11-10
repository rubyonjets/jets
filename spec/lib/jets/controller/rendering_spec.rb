describe Jets::Controller::Base do
  let(:controller) {
    controller = StoresController.new({}, nil, "new")
    controller.new
    controller
  }

  context "render called" do
    it "render :new" do
      status, headers, body = controller.render(:new)
      expect(body).to respond_to(:each)
    end

    it "render new" do
      status, headers, body = controller.render("new")
      expect(body).to respond_to(:each)
    end

    it "render stores/new" do
      status, headers, body = controller.render("stores/new")
      expect(body).to respond_to(:each)
    end

    it "render template: store/new" do
      status, headers, body = controller.render(template: "stores/new")
      expect(body).to respond_to(:each)
    end

    it "render json" do
      status, headers, body = controller.render(json: {my: "data"})
      expect(body).to respond_to(:each)
    end

    it "render file" do
      status, headers, body = controller.render(file: "#{Jets.root}public/assets/a.txt")
      expect(body).to respond_to(:each)
    end

    it "render plain" do
      status, headers, body = controller.render(plain: "text")
      expect(body).to respond_to(:each)
      expect(headers["Content-Type"]).to eq "text/html; charset=utf-8"
    end

    it "render status: 404" do
      status, headers, body = controller.render(status: 404)
      expect(status).to eq "404"
    end
  end

  context "ensure_render implicitly called due to no previous rendering" do
    it "ensure_render" do
      status, headers, body = controller.ensure_render
      expect(body).to respond_to(:each)
    end
  end
end
