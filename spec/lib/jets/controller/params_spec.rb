describe Jets::Controller::Params do
  let(:controller) { PostsController.new(event, nil, "update") }

  context "update action called" do
    let(:event) do
      {
        "headers" => {
          "content-type" => "application/x-www-form-urlencoded; charset=UTF-8"
        },
        "body" => "name=John&location=Boston"
      }
    end
    it "params" do
      params = controller.send(:params)
      expect(params.keys).to include("name")
    end

  end

  context "real put request from api gateway to aws lambda" do
    let(:event) do
      {
        "headers" => {
          "Content-Type"=>"application/x-www-form-urlencoded"
        },
        "body" =>
          "utf8=%E2%9C%93&authenticity_token=TRdBlqH9zQ1TW7MBeZ38pb4IeTPf8MJOmtPM6ft8XW2g3IoD3ZBBQ5%2BVa8H0qkeDg%2B%2Bw%2BwueYvkphMH3r3gCgw%3D%3D&post%5Btitle%5D=Test+Post+1&commit=Submit"
      }
    end
    it "params2" do
      params = controller.send(:params)
      expect(params["post"]["title"]).to eq "Test Post 1"
    end
  end

  context "multipart form data in body" do
    context "simple form" do
      let(:event) { multipart_event(:simple_form) }
      it "params" do
        params = controller.send(:params)
        expect(params["name"]).to eq "Tung"
        expect(params["title"]).to eq "Mr"
      end
    end

    context "binary" do
      let(:event) { multipart_event(:binary) }
      it "params" do
        # Example content-type: "multipart/form-data; boundary=----WebKitFormBoundaryB78dBBqs2MSBKMoX",
        # pp event

        params = controller.send(:params)
        expect(params["submit-name"]).to eq "Larry"
        expect(params["files"]).to be_a(ActionDispatch::Http::UploadedFile)
        # expect(params["files"]["filename"]).to eq "rack-logo.png"
        # expect(params["files"]["type"]).to eq "image/png"
        # expect(params["files"]["name"]).to eq "files"
        # expect(params["files"]["tempfile"]).to be_a(Tempfile)
      end
    end

    context "nested" do
      let(:event) { multipart_event(:nested) }
      it "params" do
        params = controller.send(:params)
        expect(params["foo"]["submit-name"]).to eq "Larry"
        expect(params["foo"]["files"]).to be_a(ActionDispatch::Http::UploadedFile)
        # expect(params["foo"]["files"]["filename"]).to eq "file1.txt"
        # expect(params["foo"]["files"]["type"]).to eq "text/plain"
        # expect(params["foo"]["files"]["name"]).to eq "foo[files]"
        # expect(params["foo"]["files"]["tempfile"]).to be_a(Tempfile)
      end
    end

    context "base64 encoded simple form" do
      let(:event) { multipart_event(:simple_form, base64: true) }
      it "params" do
        params = controller.send(:params)
        expect(params["name"]).to eq "Tung"
        expect(params["title"]).to eq "Mr"
      end
    end
  end
end
