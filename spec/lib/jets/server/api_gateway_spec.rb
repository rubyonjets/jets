describe Jets::Server::ApiGateway do
  it "call" do
    env = { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    triplet = Jets::Server::ApiGateway.call(env)
    expect(triplet.size).to be 3
  end
end
