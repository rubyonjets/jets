describe Jets::CLI::Curl::Request do
  let :request do
    described_class.new(options)
  end

  describe "jets url /" do
    let :options do
      # Example:
      # {
      #   function: "controller",
      #   verbose: true,
      #   request: "GET",
      #   headers: {},
      #   trim: true,
      #   data: "@data.json",
      #   path: "/"
      # }
      {path: "/", trim: true}
    end

    it "convert payload" do
      hash = JSON.parse(request.payload) # payload is a JSON string
      expect(hash["rawPath"]).to eq "/"
    end

    # Sanity check
    it "invoke" do
      mocked_response = {statusCode: 200, body: "body"}
      allow(request).to receive(:invoke).and_return(mocked_response)
      # stub methods
      allow(request).to receive(:warn)
      allow(request).to receive(:function_name)

      response = request.run
      expect(response).to eq mocked_response
    end
  end
end
