class TestSimpleController < Jets::Controller::Base
  layout :application

  def handler1; end
  def handler2; end
end

describe Jets::Controller::Base do
  let(:controller) { TestSimpleController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "class methods" do
    it "responds to rescue_from method" do
      expect(Jets::Controller::Base.respond_to?(:rescue_from)).to be true
    end
  end

  context "general" do
    let(:event) { {} }
    it "lambda_functions returns public user-defined methods" do
      expect(controller.lambda_functions).to eq(
        [:handler1, :handler2]
      )
    end

    it "layout set to application" do
      expect(controller.class.layout).to eq "application"
    end
  end

  context "normal lambda function integration request" do
    let(:event) { {"key1" => "value1", "key2" => "value2"} }
  end

  context "AWS_PROXY lambda proxy integration request from api gateway" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request.json") }

    it "#render returns rack triplet" do
      status, headers, body = controller.send(:render, json: {"my": "data"})
      expect(status).to eq "200"
      expect(headers).to be_a(Hash)
      expect(body).to respond_to(:each)
    end

    # Spec is to help understand the AWS_PROXY request format and
    # help document out important elements.
    it "expects AWS_PROXY request format" do
      event = controller.event
      # Example of AWS_PROXY compatible request format
      # {
      #   "statusCode": 200,
      #   "body": "must be a string, even if it is json, it should be a string"
      # }
      expect(event["resource"]).to eq "/posts"
      expect(event["path"]).to eq "/posts"
      expect(event["httpMethod"]).to eq "POST"
      expect(event["headers"]).to be_a(Hash)
      expect(event["queryStringParameters"]).to be_a(Hash) # or nil
      expect(event["pathParameters"]).to eq nil # or Hash
      expect(event["stageVariables"]).to eq nil # or Hash
      expect(event["requestContext"]).to be_a(Hash)
      expect(event["body"]).to be_a(String)
      expect(event["isBase64Encoded"]).to eq false
    end

    it "adds cors headers" do
      status, headers, body = controller.send(:render, json: {"my": "data"})
      expect(headers.keys).to_not include("Access-Control-Allow-Origin")
      expect(headers.keys).to_not include("Access-Control-Allow-Credentials")
    end
  end

  context "json passed in body" do
    let(:event) do
      {
        "queryStringParameters" => {"qs-key" => "qs-value"},
        "pathParameters" => {"path-key" => "path-value"},
        "body" => "{\"body-key1\": \"body-value1\", \"body-key2\": \"body-value2\"}"
      }
    end
    it "params merges all types of parameters together" do
      params = controller.send(:params)
      expect(params.keys.sort).to eq(%w[qs-key path-key body-key1 body-key2].sort)
    end
  end

  context "invalid json passed in body" do
    let(:event) do
      {
        "body" => "{\"body-key1mm.,,, \"body-key2\": \"body-value2\"}"
      }
    end
    it "not error" do
      params = controller.send(:params)
      expect(params.keys).to eq([])
    end
  end

  context "post data from form with content-type application/x-www-form-urlencoded" do
    let(:meth) { "create" }
    let(:event) do
      {
        "headers" => {
          "content-type" => "application/x-www-form-urlencoded",
        },
        "body" => "article%5Btitle%5D=test1&article%5Bbody%5D=test2&article%5Bpublished%5D=yes&commit=Submit"
      }
    end
    it "parse application/x-www-form-urlencoded form data" do
      params = controller.send(:params)
      expect(params).to eq({
        "article" => {
          "title" => "test1",
          "body" => "test2",
          "published" => "yes"
        },
        "commit" => "Submit"
      })
    end
  end

  context "stores" do
    let(:meth) { "index" }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/stores/index.json") }

    it "headers" do
      controller.set_header("Custom", "MyHeader")
      expect(controller.response.headers).to eq("Custom" => "MyHeader")
    end

    it "process headers" do
      resp = StoresController.process(event, {}, :index)
      expect(resp["headers"]["Set-Cookie"]).to eq "foo=bar"
    end
  end

  context "posts index" do
    let(:meth) { "index" }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }

    it "new adapter" do
      resp = PostsController.process(event, {}, :index)
      expect(resp['statusCode']).to eq "200"
      expect(resp['headers']).to include('X-Runtime') # confirm going through full middleware stack
      # expect(body.read).to eq "whatever"
      expect(resp['headers']['x-jets-base64']).to eq "no"
    end
  end

  describe "#log_start" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request.json") }

    context "When Jets.config is set with filtered_parameters" do
      it "Logs event and params with sensitive data masked" do
        Jets.config.controllers.filtered_parameters = [:a, :key1]  #a from queryStringParameters and key1 from body

        expect(Jets.logger).to receive(:info).with('  Parameters: {"key3":"value3","key2":"value2","key1":"[FILTERED]","a":"[FILTERED]","b":"2"}')

        expected_event_log = '  Event: {"resource":"/posts","path":"/posts","httpMethod":"POST","headers":{"Accept":"*/*","Accept-Encoding":"gzip, deflate","cache-control":"no-cache","CloudFront-Forwarded-Proto":"https","CloudFront-Is-Desktop-Viewer":"true","CloudFront-Is-Mobile-Viewer":"false","CloudFront-Is-SmartTV-Viewer":"false","CloudFront-Is-Tablet-Viewer":"false","CloudFront-Viewer-Country":"US","Content-Type":"text/plain","Host":"uhghn8z6t1.execute-api.us-east-1.amazonaws.com","Postman-Token":"7166b11b-59de-4e7b-ad35-24e556b7a083","User-Agent":"PostmanRuntime/6.4.1","Via":"1.1 55676da1e5c0a9c4e60a94a95b01dc04.cloudfront.net (CloudFront)","X-Amz-Cf-Id":"iERhUw6ghRnv1uRYfxJaUsDGWVbERFSZ4K00CIgZtJ0T6yeFdItMeQ==","X-Amzn-Trace-Id":"Root=1-59f50229-587ec5271678236e50ad91b1","X-Forwarded-For":"69.42.1.180, 54.239.203.100","X-Forwarded-Port":"443","X-Forwarded-Proto":"https"},"queryStringParameters":{"a":"[FILTERED]","b":"2"},"pathParameters":null,"stageVariables":null,"requestContext":{"path":"/stag/posts","accountId":"123456789012","resourceId":"c0yhg8","stage":"stag","requestId":"e5c39604-bc2d-11e7-abbe-1baaa0f8e02e","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"apiKey":"","sourceIp":"69.42.1.180","accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"PostmanRuntime/6.4.1","user":null},"resourcePath":"/posts","httpMethod":"POST","apiId":"uhghn8z6t1"},"body":"{\"key3\":\"value3\",\"key2\":\"value2\",\"key1\":\"[FILTERED]\"}","isBase64Encoded":false}'
        expect(Jets.logger).to receive(:info).with(expected_event_log)
        expect(Jets.logger).to receive(:info).at_least(:once)

        controller.log_start
      end
    end

    context "When Jets.config is not set with filtered_parameters" do
      it "Logs event and params with original payload" do
        Jets.config.controllers.filtered_parameters = []

        expect(Jets.logger).to receive(:info).with('  Parameters: {"key3":"value3","key2":"value2","key1":"value1","a":"1","b":"2"}')

        expected_event_log = '  Event: {"resource":"/posts","path":"/posts","httpMethod":"POST","headers":{"Accept":"*/*","Accept-Encoding":"gzip, deflate","cache-control":"no-cache","CloudFront-Forwarded-Proto":"https","CloudFront-Is-Desktop-Viewer":"true","CloudFront-Is-Mobile-Viewer":"false","CloudFront-Is-SmartTV-Viewer":"false","CloudFront-Is-Tablet-Viewer":"false","CloudFront-Viewer-Country":"US","Content-Type":"text/plain","Host":"uhghn8z6t1.execute-api.us-east-1.amazonaws.com","Postman-Token":"7166b11b-59de-4e7b-ad35-24e556b7a083","User-Agent":"PostmanRuntime/6.4.1","Via":"1.1 55676da1e5c0a9c4e60a94a95b01dc04.cloudfront.net (CloudFront)","X-Amz-Cf-Id":"iERhUw6ghRnv1uRYfxJaUsDGWVbERFSZ4K00CIgZtJ0T6yeFdItMeQ==","X-Amzn-Trace-Id":"Root=1-59f50229-587ec5271678236e50ad91b1","X-Forwarded-For":"69.42.1.180, 54.239.203.100","X-Forwarded-Port":"443","X-Forwarded-Proto":"https"},"queryStringParameters":{"a":"1","b":"2"},"pathParameters":null,"stageVariables":null,"requestContext":{"path":"/stag/posts","accountId":"123456789012","resourceId":"c0yhg8","stage":"stag","requestId":"e5c39604-bc2d-11e7-abbe-1baaa0f8e02e","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"apiKey":"","sourceIp":"69.42.1.180","accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"PostmanRuntime/6.4.1","user":null},"resourcePath":"/posts","httpMethod":"POST","apiId":"uhghn8z6t1"},"body":"{\n  \"key3\": \"value3\",\n  \"key2\": \"value2\",\n  \"key1\": \"value1\"\n}","isBase64Encoded":false}'
        expect(Jets.logger).to receive(:info).with(expected_event_log)
        expect(Jets.logger).to receive(:info).at_least(:once)

        controller.log_start
      end
    end
  end

  describe "#log_finish" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request.json") }

    it 'logs completion' do
      status = 200
      took = 1.5
      expected_event_log = "Completed Status Code #{status} in #{took}s"
      expect(Jets.logger).to receive(:info).with(expected_event_log)

      controller.log_finish(status: status, took: took)
    end
  end
end
