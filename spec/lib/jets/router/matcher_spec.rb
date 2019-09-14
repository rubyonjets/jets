describe Jets::Controller::Middleware::Local::RouteMatcher do
  let(:matcher) { Jets::Router::Matcher.new(path, method) }

  context "get /" do
    let(:path) { "/" }
    let(:method) { "GET" }

    it "match? finds root route" do
      route = Jets::Router::Route.new(
        path: "/",
        method: :get,
        to: "posts#new",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get posts/:id/edit" do
    let(:path) { "/posts/tung/edit" }
    let(:method) { "GET" }

    it "match? finds highest precedence route" do
      # In this case the catchall and the capture route matches
      # But the matcher finds the route with the highest precedence
      route = Jets::Router::Route.new(
        path: "*catchall",
        method: :get,
        to: "public_files#show",
      )
      found = matcher.match?(route)
      expect(found).to be true

      route = Jets::Router::Route.new(
        path: "posts/:id/edit",
        method: :get,
        to: "posts#edit",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get everything/else catchall route" do
    let(:path) { "/everything/else" }
    let(:method) { "GET" }

    it "match?" do
      route = Jets::Router::Route.new(
        path: "*catchall",
        method: :get,
        to: "public_files#catchall",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get posts/:id/edit" do
    let(:path) { "/posts/tung/edit" }
    let(:method) { "GET" }
    
    it "match?" do
      route = Jets::Router::Route.new(
        path: "posts/:id/edit",
        method: :get,
        to: "posts#edit",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with get" do
    let(:path) { "/comments/hot" }
    let(:method) { "GET" }

    it "route_found?" do
      route = Jets::Router::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with post" do
    let(:path) { "/comments/hot" }
    let(:method) { "POST" }

    it "match?" do
      route = Jets::Router::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with non-matching path" do
    let(:path) { "/some/other/path" }
    let(:method) { "GET" }

    it "match?" do
      route = Jets::Router::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.match?(route)
      expect(found).to be false
    end
  end

  context "get admin/pages" do
    let(:path) { "/admin/pages" }
    let(:method) { "GET" }

    it "route_found?" do
      route = Jets::Router::Route.new(
        path: "admin/pages",
        method: :get,
        to: "admin/pages#index",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get others/my/long/path - proxy path route" do
    let(:path) { "others/my/long/path" }
    let(:method) { "GET" }

    it "match?" do
      route = Jets::Router::Route.new(
        path: "others/*proxy",
        method: :get,
        to: "others#all",
      )
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get others/my/long/path - proxy path route" do
    let(:path) { "others2/my/long/path" }
    let(:method) { "GET" }

    it "not match?" do
      route = Jets::Router::Route.new(
        path: "others/*proxy",
        method: :get,
        to: "others#all",
      )
      found = matcher.match?(route)
      expect(found).to be false
    end
  end
end
