require "spec_helper"

describe Jets::Server::LambdaAwsProxy do
  let(:proxy) { Jets::Server::LambdaAwsProxy.new(route, env) }
  let(:route) do
    Jets::Route.new(
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

  context "post form application/x-www-form-urlencoded" do
    let(:env) do
      JSON.load(IO.read("spec/fixtures/dumps/rack/form-post.json"))
    end
    it "mapping of rack headers should match the lambda proxy headers" do
      # Annoying. The headers part part of the AWS Lambda proxy structure
      # does not consisently use the same casing scheme for the the header keys.
      # So sometimes it looks like this:
      #   Accept-Encoding
      # and sometimes it is looks like this:
      #   cache-control
      headers = proxy.request_headers
      expect(headers["content-type"]).to eq "application/x-www-form-urlencoded"
      expect(headers["cache-control"]).to eq "max-age=0"
      expect(headers["origin"]).to eq "http://localhost:8888"
      expect(headers["upgrade-insecure-requests"]).to eq "1"
    end
  end
end
