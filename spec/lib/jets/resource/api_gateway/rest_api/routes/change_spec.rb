describe Jets::Resource::ApiGateway::RestApi::Routes::Change do
  let(:change) do
    Jets::Resource::ApiGateway::RestApi::Routes::Change.new
  end

  context "no changes detected" do
    it "changed" do
      # Use new routes as the "deployed" routes that thats one way to mimic that
      # no routes have been changed
      new_routes = Jets::Router.routes
      deployed_routes = new_routes
      allow(change).to receive(:deployed_routes).and_return(deployed_routes)
      changed = change.changed?
      expect(changed).to be false
    end
  end
end
