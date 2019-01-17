describe Jets::Resource::ApiGateway::RestApi::Routes::Change::Variable do
  let(:variable) do
    Jets::Resource::ApiGateway::RestApi::Routes::Change::Variable.new
  end
  let(:new_routes) do
    new_routes = Jets::Router.routes
    new_routes.select { |r| r.path.include?(':') }
  end

  context "no changes detected" do
    it "changed" do
      # Use new routes as the "deployed" routes that thats one way to mimic that
      # no routes have been changed
      new_routes = Jets::Router.routes
      deployed_routes = new_routes.clone
      allow(variable).to receive(:deployed_routes).and_return(deployed_routes)

      changed = variable.changed?

      expect(changed).to be false
    end
  end

  context "yes changes detected" do
    it "changed" do
      new_routes = [Jets::Route.new(path: "posts/:id", to: "posts#show", method: :get)]
      deployed_routes = [Jets::Route.new(path: "posts/:post_id", to: "posts#show", method: :get)]

      allow(variable).to receive(:deployed_routes).and_return(deployed_routes)
      allow(variable).to receive(:new_routes).and_return(new_routes)

      changed = variable.changed?

      expect(changed).to be true
    end
  end
end
