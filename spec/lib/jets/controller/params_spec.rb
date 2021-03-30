describe Jets::Controller::Params do
  let(:controller) { PostsController.new(event, nil, "update") }

  context "with unicode" do
    context "body parameter" do
      let(:event) do
        {
          "headers" => {
            "content-type" => "application/x-www-form-urlencoded; charset=UTF-8"
          },
          "body" => "name=#{CGI.escape("太郎")}&location=#{CGI.escape("東京")}"
        }
      end
      it "decode values" do
        params = controller.send(:params)
        expect(params["name"]).to eq "太郎"
      end
    end

    context "path parameter" do
      let(:event) do
        {
          "pathParameters" => {
            "name" => CGI.escape("太郎"),
            "location" => CGI.escape("東京"),
          }
        }
      end
      it "decode values" do
        params = controller.send(:params)
        expect(params["name"]).to eq "太郎"
      end
    end

    context "query parameter" do
      let(:event) do
        {
          "queryStringParameters" => {
            "name" => [
              CGI.escape("太郎"),
              CGI.escape("鈴木"),
            ],
            "location" => CGI.escape("東京"),
          }
        }
      end
      it "decode values" do
        params = controller.send(:params)
        expect(params["name"][0]).to eq "太郎"
        expect(params["name"][1]).to eq "鈴木"
      end
    end
  end

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

  describe "#filtered_params" do
    let(:event) { {} }

    it "Forwards options to params" do
      expect(controller).to receive(:params).with(body_parameters: false, path_parameters: true, raw: true)

      controller.send(:filtered_parameters, body_parameters: false, path_parameters: true, raw: false)
    end

    context "With plain filtered parameters" do
      let(:event) { multipart_event(:simple_form) }

      it "Masks provided keys as [FILTERED]" do
        Jets.config.controllers.filtered_parameters = [:title]

        filtered_params = controller.send(:filtered_parameters)
        expect(filtered_params).to eq(
          "name" => "Tung",
          "title" => "[FILTERED]"
        )
      end
    end

    context "With nested filtered parameters" do
      let(:event) { multipart_event(:nested) }

      it "Masks provided keys as [FILTERED]" do
        Jets.config.controllers.filtered_parameters = ["foo.submit-name"]

        filtered_params = controller.send(:filtered_parameters)
        expect(filtered_params["foo"]["submit-name"]).to eq("[FILTERED]")
      end
    end

    context "With nested array filtered parameters" do
      let(:event) do
        {
          "headers" => {
            "content-type" => "application/x-www-form-urlencoded; charset=UTF-8"
          },
          "body" => "users[0][name]=John&users[0][location]=Boston&users[1][name]=Luke&users[1][location]=Chicago"
        }
      end

      it "Masks provided keys as [FILTERED]" do
        Jets.config.controllers.filtered_parameters = [/users\.\d+\.name/]

        filtered_params = controller.send(:filtered_parameters)
        expect(filtered_params).to eq(
          "users" => {
            "0" => {
              "name" => "[FILTERED]",
              "location" => "Boston"
            },
            "1" => {
              "name" => "[FILTERED]",
              "location" => "Chicago"
            }
          }
        )
      end
    end
  end
end
