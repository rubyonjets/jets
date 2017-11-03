require "spec_helper"

describe Jets::Server::RouteMatcher do
  let(:matcher) { Jets::Server::RouteMatcher.new(env) }

  context "get posts/:id/edit" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id/edit"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung", "REQUEST_METHOD" => "GET" }
    end
    it "find_route exact match" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "GET"
    end
  end

  context "get posts/:id" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/anything", "REQUEST_METHOD" => "GET" }
    end
    it "find_route slash at the end of the pattern disqualified the match" do
      route = matcher.find_route
      expect(route).to be nil
    end
  end

  context "put posts/:id exact match" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung", "REQUEST_METHOD" => "PUT" }
    end
    it "find_route" do
      route = matcher.find_route
      expect(route.path).to eq "posts/:id"
      expect(route.method).to eq "PUT"
    end
  end

  context "get posts/:id/edit" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    end
    it "route_found?" do
      route = Jets::Route.new(
        path: "posts/:id/edit",
        method: :get,
        to: "posts#edit",
      )
      found = matcher.route_found?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with get" do
    let(:env) do
      { "PATH_INFO" => "/comments/hot", "REQUEST_METHOD" => "GET" }
    end
    it "route_found?" do
      route = Jets::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.route_found?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with post" do
    let(:env) do
      { "PATH_INFO" => "/comments/hot", "REQUEST_METHOD" => "POST" }
    end
    it "route_found?" do
      route = Jets::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.route_found?(route)
      expect(found).to be true
    end
  end

  context "any comments/hot with non-matching path" do
    let(:env) do
      { "PATH_INFO" => "/some/other/path", "REQUEST_METHOD" => "GET" }
    end
    it "route_found?" do
      route = Jets::Route.new(
        path: "comments/hot",
        method: :any,
        to: "comments#hot",
      )
      found = matcher.route_found?(route)
      expect(found).to be false
    end
  end
end
