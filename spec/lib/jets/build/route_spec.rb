require "spec_helper"

describe "Route" do
  it "builds up routes in memory" do
    route = Jets::Build::Route.new(path: "/posts", method: :get, to: "posts#index")
    expect(route.path).to eq "/posts"
    expect(route.to).to eq "posts#index"
    expect(route.method).to eq "GET"
  end
end
