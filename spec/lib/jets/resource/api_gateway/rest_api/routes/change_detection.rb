describe Jets::Resource::ApiGateway::RestApi do
  let(:detection) { Jets::Resource::ApiGateway::RestApi::ChangeDetection.new }

  context "general" do
    it "default binary media type" do
      expect(detection.new_binary_media_types).to eq ["multipart/form-data"]
    end
  end

  # TODO: have a spec in place right now for basic syntax checking. Eventually add
  # more specs in the future.
  # context "changes detected" do
  #   it "reuses the existing rest api logical id" do
  #   end
  # end

  # context "no changes detected" do
  #   it "updates the rest api logical id" do
  #   end
  # end
end
