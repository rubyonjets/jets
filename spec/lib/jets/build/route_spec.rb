require "spec_helper"

describe "Route" do
  it "builds up route in memory" do
    route = Jets::Build::Route.new(path: "posts", method: :get, to: "posts#index")
    expect(route.path).to eq "posts"
    expect(route.to).to eq "posts#index"
    expect(route.method).to eq "GET"
    expect(route.controller_name).to eq "PostsController"
  end

  it "extract_parameters" do
    route = Jets::Build::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit")
    parameters = route.extract_parameters("posts/tung/edit")
    expect(parameters).to eq("id" => "tung")
  end
end
