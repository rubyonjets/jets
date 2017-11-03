require "spec_helper"

describe Jets::Server::LambdaAwsProxy do
  let(:proxy) { Jets::Server::LambdaAwsProxy.new(route, env) }
  let(:route) do
    Jets::Build::Route.new(
      path: "posts/:id/edit",
      method: :get,
      to: "posts#edit",
    )
  end

  context "get posts/:id/edit" do
    let(:env) do
      { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
    end
    it "response" do
      triplet = proxy.response
      expect(triplet.size).to be 3

      status, headers, body = triplet
      expect(body).to respond_to(:each)
    end
  end

  context "request headers" do
    let(:env) do
      {
        "SERVER_SOFTWARE" => "WEBrick/1.3.1 (Ruby/2.2.2/2015-04-13)",
        "HTTP_USER_AGENT" => "PostmanRuntime/6.4.1",
        "HTTP_HOST" => "localhost:8888",
      }
    end
    it "normalizes them" do
      headers = proxy.request_headers
      # Filters out the non-HTTP_ header and prettifies the keys
      # This is what the AWS_PROXY lambda integration does
      expect(headers).to eq(
        "User-Agent" => "PostmanRuntime/6.4.1",
        "Host" => "localhost:8888",
      )
    end
  end

  context "query string parameters" do
    let(:env) do
      {
        "QUERY_STRING" => "foo=bar&cat=dog",
      }
    end
    it "normalizes them" do
      parameters = proxy.query_string_parameters
      # This is what the AWS_PROXY lambda integration does
      expect(parameters).to eq(
        "foo" => "bar",
        "cat" => "dog",
      )
    end
  end
end
