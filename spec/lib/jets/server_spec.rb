require "spec_helper"

describe Jets::Server do
  it "call" do
    env = { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    triplet = Jets::Server.call(env)
    expect(triplet.size).to be 3
  end
end
