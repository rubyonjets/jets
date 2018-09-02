describe Jets::Resource::Route do
  let(:resource) { Jets::Resource::Route.new(route) }
  let(:route) do
    Jets::Route.new(path: "posts", method: :get, to: "posts#index")
  end

  context "route" do
    it "attributes" do
      pp resource.attributes

      # attributes = permission.attributes # attributes
      # # the class shows up as the fake double class, which is fine for the spec
      # expect(attributes.logical_id).to eq "#[Double :task]DisableUnusedCredentialsPermission1"
      # properties = attributes.properties
      # # pp properties # uncomment to debug
      # expect(properties["Principal"]).to eq "events.amazonaws.com"
      # expect(properties["SourceArn"]).to eq "!GetAtt #[Double :task]DisableUnusedCredentialsEventsRule1.Arn"
    end
  end
end

