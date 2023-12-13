describe Jets::Shim::Response::Alb do
  let :response do
    described_class.new(triplet)
  end

  describe "apigw" do
    let :triplet do
      [
        200,
        {"Content-Type" => "application/json"},
        ["body"]
      ]
    end

    it "has alb structure" do
      h = response.translate
      expect(h.keys.size).to eq 5
      expect(h.keys.sort).to eq [:body, :headers, :isBase64Encoded, :statusCode, :statusDescription]
      expect(h[:statusDescription]).to eq "200 OK"
    end
  end
end
