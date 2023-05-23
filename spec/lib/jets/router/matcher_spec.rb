describe Jets::Router::Matcher do
  let(:matcher) do
    matcher = Jets::Router::Matcher.new(route_set)
    matcher.instance_variable_set(:@request_path, request_path) if request_path
    matcher.instance_variable_set(:@request_method, request_method) if request_method
    matcher
  end
  let(:route_set) do
    double(:route_set, ordered_routes: ordered_routes)
  end
  # Defaults: specs will override and use accordingly
  let(:ordered_routes) { [] }
  let(:request_path) { nil }
  let(:request_method) { "GET" }

  def build_env(path, method)
    {
      "PATH_INFO" => path,
      "REQUEST_METHOD" => method,
    }
  end

  def route(options)
    options = {path: options} if options.is_a?(String)
    defaults = {
      http_method: "GET",
      # path: "/",
      # to: "posts#new", # dont really have to set to for specs
    }
    options.reverse_merge!(defaults)
    Jets::Router::Route.new(options)
  end

  context "get /" do
    let(:ordered_routes) do
      [route("/")]
    end

    it "match? finds root route" do
      env = build_env("/", "GET")
      route = matcher.find_by_env(env)
      expect(route).not_to be(nil)
    end
  end

  context "get posts/:id/edit" do
    let(:request_path) { "/posts/tung/edit" }

    it "match? finds highest precedence route" do
      # In this case the catchall and the capture route matches
      # But the matcher finds the route with the highest precedence
      route1 = route("*catchall")
      found = matcher.match?(route1)
      expect(found).to be true

      route2 = route("posts/:id/edit")

      found = matcher.match?(route2)
      expect(found).to be true
    end
  end

  context "get everything/else catchall route" do
    let(:request_path) { "/everything/else" }

    it "match?" do
      route = route("*catchall")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get posts/:id/edit" do
    let(:request_path) { "/posts/tung/edit" }

    it "match?" do
      route = route("posts/:id/edit")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with get" do
    let(:request_path) { "/comments/hot" }

    it "route_found?" do
      route = route("comments/hot")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with post" do
    let(:request_path)   { "/comments/hot" }
    let(:request_method) { "POST" }

    it "match?" do
      route = route(path: "comments/hot", http_method: "POST")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with non-matching path" do
    let(:request_path) { "/some/other/path" }

    it "match?" do
      route = route("comments/hot")
      found = matcher.match?(route)
      expect(found).to be false
    end
  end

  context "get admin/pages" do
    let(:request_path) { "/admin/pages" }

    it "route_found?" do
      route = route("admin/pages")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get others/my/long/path - proxy path route" do
    let(:request_path) { "others/my/long/path" }

    it "match?" do
      route = route("others/*proxy")
      found = matcher.match?(route)
      expect(found).to be true
    end
  end

  context "get others/my/long/path - proxy path route" do
    let(:request_path) { "others2/my/long/path" }

    it "not match?" do
      route = route("others/*proxy")
      found = matcher.match?(route)
      expect(found).to be false
    end
  end
end
