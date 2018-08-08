describe Jets::Controller::Params do
  let(:controller) {
    controller = PostsController.new(event, nil, "update")
    controller.new
    controller
  }

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
end
