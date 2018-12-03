describe Jets::Resource::ApiGateway::RestApi do
  let(:routes) do
    Jets::Resource::ApiGateway::RestApi::Routes.new
  end

  context "changes detected" do
    it "changed" do
      # All we have to do is fake at least one route that has been changed
      route = Jets::Route.new(path: "posts/:id/edit", method: :get, to: "toys#edit")
      deployed_routes = [ route ]
      allow(routes).to receive(:build).and_return(deployed_routes)
      changed = routes.changed?
      expect(changed).to be true
    end
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

  context "general" do
    it "recreate_to" do
      method_uri = "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:112233445566:function:demo-test-posts_controller-new/invocations"
      to = routes.recreate_to(method_uri)
      expect(to).to eq "posts#new"

      method_uri = "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:536766270177:function:demo-test-jets-rack_controller-process/invocations"
      to = routes.recreate_to(method_uri)
      expect(to).to eq "jets/rack#process"
    end

    it "recreate_path" do
      path = "/posts/{id}/edit"
      path = routes.recreate_path(path)
      expect(path).to eq "posts/:id/edit"

      path = "/{catchall+}"
      path = routes.recreate_path(path)
      expect(path).to eq "*catchall"

      path = "/others/{proxy+}"
      path = routes.recreate_path(path)
      expect(path).to eq "others/*proxy"
    end
  end
end
