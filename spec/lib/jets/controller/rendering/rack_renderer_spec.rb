describe Jets::Controller::Rendering::RackRenderer do
  let(:renderer) do
    controller = double(:null).as_null_object
    Jets::Controller::Rendering::RackRenderer.new(controller)
  end

  it "rackify_headers" do
    input = {"host"=>"localhost:8888",
      "user-agent"=>"curl/7.53.1",
      "accept"=>"*/*",
      "version"=>"HTTP/1.1",
      "x-amzn-trace-id"=>"Root=1-5bde5b19-61d0d4ab4659144f8f69e38f"}
    output = renderer.rackify_headers(input)
    expect(output).to eq(
      {"HTTP_HOST"=>"localhost:8888",
       "HTTP_USER_AGENT"=>"curl/7.53.1",
       "HTTP_ACCEPT"=>"*/*",
       "HTTP_VERSION"=>"HTTP/1.1",
       "HTTP_X_AMZN_TRACE_ID"=>"Root=1-5bde5b19-61d0d4ab4659144f8f69e38f"}
    )
  end
end
