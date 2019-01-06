describe Jets::Resource::ApiGateway::RestApi do
  let(:routes) do
    Jets::Resource::ApiGateway::RestApi::Routes.new
  end

  context "no changes detected" do
    it "changed" do
      # Use new routes as the "deployed" routes that thats one way to mimic that
      # no routes have been changed
      new_routes = Jets::Router.routes
      deployed_routes = new_routes
      allow(routes).to receive(:build).and_return(deployed_routes)
      changed = routes.changed?
      expect(changed).to be false
    end
  end
end
