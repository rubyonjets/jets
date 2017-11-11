require "spec_helper"

describe "Route" do
  it "evaluates route info" do
    route = Jets::Route.new(path: "posts", method: :get, to: "posts#index")
    expect(route.path).to eq "posts"
    expect(route.to).to eq "posts#index"
    expect(route.method).to eq "GET"
    expect(route.controller_name).to eq "PostsController"
  end

  it "extract_parameters" do
    route = Jets::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit")
    parameters = route.extract_parameters("posts/tung/edit")
    expect(parameters).to eq("id" => "tung")
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
end
