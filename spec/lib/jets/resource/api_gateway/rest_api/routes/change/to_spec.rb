describe Jets::Resource::ApiGateway::RestApi::Routes::Change::To do
  let(:to) do
    Jets::Resource::ApiGateway::RestApi::Routes::Change::To.new
  end

  context "no changes detected" do
    it "changed" do
      # Use new routes as the "deployed" routes that thats one way to mimic that
      # no routes have been changed
      new_routes = Jets::Router.routes
      deployed_routes = new_routes.clone
      allow(to).to receive(:deployed_routes).and_return(deployed_routes)

      changed = to.changed?

      expect(changed).to be false
    end
  end

  context "yes changes detected" do
    it "changed" do
      new_routes = Jets::Router.routes
      deployed_routes = new_routes.clone
      # current to value is posts#index , change it to trigger a change
      new_routes[0] = Jets::Route.new(:path=>"", :to=>"toys#index", :method=>:get, :root=>true)

      allow(to).to receive(:deployed_routes).and_return(deployed_routes)
      allow(to).to receive(:new_routes).and_return(new_routes)

      changed = to.changed?

      expect(changed).to be true
    end
  end
end
