describe Jets::Rack::ApiGateway do
  let(:builder) do
    Jets::Rack::ApiGateway.new(triplet)
  end

  context "rack triplet" do
    let(:triplet) do
      ['200', {'Content-Type' => 'text/html'}, ['content body']]
    end

    describe "build" do
      it "converts event to rack env hash" do
        resp = builder.build
        expect(resp).to eq(
          {
            "statusCode" => "200",
            "headers" => {'Content-Type' => 'text/html'},
            "body" => 'content body',
            # "isBase64Encoded" => "base64",
          }
        )
      end
    end
  end
end
