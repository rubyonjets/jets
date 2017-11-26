require "spec_helper"

describe "Route" do
  it "evaluates route info" do
    route = Jets::Route.new(path: "posts", method: :get, to: "posts#index")
    expect(route.path).to eq "posts"
    expect(route.to).to eq "posts#index"
    expect(route.method).to eq "GET"
    expect(route.controller_name).to eq "PostsController"
  end

  context "route with namespace" do
    it "evaluates route info" do
      route = Jets::Route.new(path: "admin/pages", method: :get, to: "admin/pages#index")
      expect(route.path).to eq "admin/pages"
      expect(route.to).to eq "admin/pages#index"
      expect(route.method).to eq "GET"
      expect(route.controller_name).to eq "Admin::PagesController"
    end
  end

  context "route with captures" do
    let(:route) do
      Jets::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit")
    end
    it "extract_parameters" do
      parameters = route.extract_parameters("posts/tung/edit")
      expect(parameters).to eq("id" => "tung")
    end

    it "api_gateway_format" do
      api_gateway_path = route.send(:api_gateway_format, route.path)
      expect(api_gateway_path).to eq "posts/{id}/edit"
    end
  end

  context "route with catchall/globbing/wildcard" do
    let(:route) do
      Jets::Route.new(path: "others/*proxy", method: :any, to: "others#all")
    end

    it "api_gateway_format" do
      api_gateway_path = route.send(:api_gateway_format, route.path)
      expect(api_gateway_path).to eq "others/{proxy+}"
    end

    it "extract_parameters" do
      parameters = route.extract_parameters("others/my/long/path")
      expect(parameters).to eq("proxy" => "my/long/path")
    end
  end

  context "route with toplevel catchall/globbing/wildcard" do
    let(:route) do
      Jets::Route.new(path: "*catchall", method: :any, to: "catch#all")
    end

    it "api_gateway_format" do
      api_gateway_path = route.send(:api_gateway_format, route.path)
      expect(api_gateway_path).to eq "{catchall+}"
    end

    it "extract_parameters for path with slashes" do
      parameters = route.extract_parameters("my/long/path")
      expect(parameters).to eq("catchall" => "my/long/path")
    end

    it "extract_parameters for path with no slashes" do
      parameters = route.extract_parameters("whatever")
      expect(parameters).to eq("catchall" => "whatever")
    end
  end

  context "route with nested catchall/globbing/wildcard" do
    let(:route) do
      Jets::Route.new(path: "nested/others/*proxy", method: :any, to: "others#all")
    end

    it "api_gateway_format" do
      api_gateway_path = route.send(:api_gateway_format, route.path)
      expect(api_gateway_path).to eq "nested/others/{proxy+}"
    end

    it "extract_parameters" do
      parameters = route.extract_parameters("nested/others/my/long/path")
      expect(parameters).to eq("proxy" => "my/long/path")
    end
  end

  context "route provided in aws api gateway format" do
    let(:route) do
      Jets::Route.new(path: "posts/{id}/edit", method: :any, to: "posts#edit")
    end

    it "extract_parameters" do
      parameters = route.extract_parameters("posts/tung/edit")
      expect(parameters).to eq("id" => "tung")
    end

    it "api_gateway_format" do
      api_gateway_path = route.send(:api_gateway_format, route.path)
      expect(api_gateway_path).to eq "posts/{id}/edit"
    end

    it "path" do
      jets_format = route.path
      expect(jets_format).to eq "posts/:id/edit"
    end

    it "ensure_jets_format" do
      jets_format = route.send(:ensure_jets_format, 'posts/{id}/edit')
      expect(jets_format).to eq "posts/:id/edit"

      jets_format = route.send(:ensure_jets_format, 'others/{proxy+}')
      expect(jets_format).to eq "others/*proxy"
    end
  end
end
