describe Jets::Controller::Middleware::Local::RouteMatcher do
  let(:matcher) { Jets::Controller::Middleware::Local::RouteMatcher.new(env) }

  context "get posts/:id/edit" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    end
    it "find_route finds highest precedence route" do
      # In this case the catchall and the capture route matches
      # But the matcher finds the route with the highest precedence
      route = Jets::Router::Route.new(
        path: "*catchall",
        method: :get,
        to: "public_files#show",
      )

      route = matcher.find_route
      expect(route.path).to eq "posts/:id/edit"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung", "REQUEST_METHOD" => "GET" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id with extension" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung.png", "REQUEST_METHOD" => "GET" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id with dash" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung-nguyen", "REQUEST_METHOD" => "GET" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/new" do
    let(:env) do
      { "PATH_INFO" => "/posts/new", "REQUEST_METHOD" => "GET" }
    end
    it "find_route exact match" do
      route = matcher.find_route
      expect(route.path).to eq "posts/new"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/anything", "REQUEST_METHOD" => "GET" }
    end
    it "find_route slash at the end of the pattern disqualified the match" do
      route = matcher.find_route
      expect(route.path).to eq "*catchall"
    end
  end

  context "put posts/:id" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung", "REQUEST_METHOD" => "PUT" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "PUT"
    end
  end

  context "get everything/else catchall route" do
    let(:env) do
      { "PATH_INFO" => "/everything/else", "REQUEST_METHOD" => "GET" }
    end

    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "*catchall"
      expect(route.method).to eq "ANY"
    end
  end
end
