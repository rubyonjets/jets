describe Jets::Controller::Response do
  let(:response) { Jets::Controller::Response.new }

  context "response" do
    it "headers" do
      expect(response.headers).to eq({})
      response.headers["Set-Cookie"] = "foo=bar"
      response.set_header("AnotherHeader", "MyValue")
      expect(response.headers).to eq({"Set-Cookie" => "foo=bar", "AnotherHeader" => "MyValue"})
    end

    it "cookies" do
      response.set_cookie(:favorite_food, "chocolate cookie")
      response.set_cookie(:favorite_color, "yellow")
      response.delete_cookie(:favorite_food)
      expect(response.headers).to eq({"Set-Cookie"=>
        "favorite_color=yellow\n" +
        "favorite_food=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"})
    end
  end
end
