describe Jets::Controller::Handler::Apigw do
  let(:apigw) do
    rack_env = Jets::Controller::RackAdapter::Env.new(event, context).convert
    Jets::Controller::Handler::Apigw.new(
      event,
      context,
      'controller',
      'index',
      rack_env
    )
  end
  let(:context) { nil }
  let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }
  let(:default_status) { 200 }
  let(:default_body) { StringIO.new(body_text) }
  let(:body_text) { 'Test body' }
  let(:default_headers) do
    {
      "Content-Type"=>"application/json",
      "x-jets-base64"=>"no",
      "Set-Cookie"=>"rack.session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVG86HVJhY2s6OlNlc3Npb246OlNlc3Npb25JZAY6D0BwdWJsaWNfaWRJIkUxZDA2NTRiMDE1NDJjZGYzM2UzMGM3YmI0NTM1MTQ0MzY2N2I3Y2YwN2ZlZGMxMmE0MTE2MzQ1YWVhYzk2MTJiBjsARkkiCGZvbwY7AEZJIgtiYXJiYXIGOwBU--e6313ca3edc4486e1482180d15273fe1d20750ef; path=/; HttpOnly",
      "access-control-allow-origin"=>"*",
      "access-control-allow-credentials"=>"true",
      "X-Runtime"=>"0.017019"
    }
  end
  let(:multi_value_headers) {
    {
      "Content-Type"=>"application/json",
      "x-jets-base64"=>"no",
      "Set-Cookie"=>[
        "cookie_a=first.cookie; path=/; HttpOnly",
        "cookie_b=second.cookie; path=/; HttpOnly",
      ],
      "access-control-allow-origin"=>"*",
      "access-control-allow-credentials"=>"true",
      "X-Runtime"=>"0.017019"
    }
  }

  describe '#convert_to_api_gateway' do
    let(:convert) { apigw.convert_to_api_gateway(default_status, default_headers, default_body) }

    it 'returns hash' do
      expect(convert).to be_a(Hash)
    end

    context 'key values' do
      it 'statusCode' do
        expect(convert['statusCode']).to eq(default_status)
      end

      context 'body' do
        it 'body is a string' do
          result = apigw.convert_to_api_gateway(default_status, default_headers, body_text)
          expect(result['body']).to eq(body_text)
        end

        it 'body is an object' do
          expect(convert['body']).to eq(body_text)
        end

        it 'base 64 body' do
          default_headers['x-jets-base64'] = 'yes'
          result = apigw.convert_to_api_gateway(default_status, default_headers, default_body)
          expect(result['body']).to eq(Base64.encode64(body_text))
        end
      end

      context 'isBase64Encoded' do
        it 'encoded' do
          default_headers['x-jets-base64'] = 'yes'
          result = apigw.convert_to_api_gateway(default_status, default_headers, default_body)
          expect(result['isBase64Encoded']).to eq(true)
        end

        it 'not encoded' do
          expect(convert['isBase64Encoded']).to eq(false)
        end
      end

      context 'adjust_for_elb' do
        it 'from elb' do
          allow(apigw).to receive(:from_elb?).and_return(true)
          expect(convert.keys).to include('statusDescription')
        end

        it 'not from elb' do
          allow(apigw).to receive(:from_elb?).and_return(false)
          expect(convert.keys).not_to include('statusDescription')
        end
      end
    end

    it 'invokes #add_response_headers' do
      resp_hash = convert.select { |key, _| %w[statusCode body isBase64Encoded].include?(key) }
      expect(apigw).to receive(:add_response_headers).with(resp_hash, default_headers)
      apigw.convert_to_api_gateway(default_status, default_headers, body_text)
    end

    it 'invokes #adjust_for_elb' do
      resp_hash = convert.select { |key, _| %w[statusCode body isBase64Encoded headers].include?(key) }
      expect(apigw).to receive(:adjust_for_elb).with(resp_hash)
      apigw.convert_to_api_gateway(default_status, default_headers, body_text)
    end
  end

  describe '#add_response_headers' do
    let(:result) { Hash.new }
    let(:call) { apigw.add_response_headers(result, multi_value_headers) }

    context 'headers' do
      before { call }

      it 'adds headers key to hash' do
        expect(result.keys).to include('headers')
      end

      it 'includes only non multivalue headers' do
        headers = result['headers']
        multi_value_headers.each do |key, val|
          if val.is_a?(Array)
            expect(headers.keys).not_to include(key)
          else
            expect(headers[key]).to eq(val)
          end
        end
      end
    end

    context 'multi value headers' do
      before { call }

      context 'has multi value headers' do
        it 'adds multiValueHeaders key to hash' do
          expect(result.keys).to include('multiValueHeaders')
        end

        it 'includes only multivalue headers' do
          headers = result['multiValueHeaders']
          multi_value_headers.each do |key, val|
            if val.is_a?(Array)
              expect(headers[key]).to eq(val)
            else
              expect(headers.keys).not_to include(key)
            end
          end
        end
      end

      context 'does not have multi value headers' do
        let(:call) { apigw.add_response_headers(result, default_headers) }

        it 'omits multiValueHeaders from hash' do
          expect(result.keys).not_to include('multiValueHeaders')
        end
      end
    end
  end

  describe '#adjust_for_elb' do
    let(:resp) { { 'statusCode' => 200 } }
    let(:call) { apigw.adjust_for_elb(resp) }

    it 'adds status description if from ELB' do
      allow(apigw).to receive(:from_elb?).and_return(true)
      expected_status = "200 #{Rack::Utils::HTTP_STATUS_CODES[200]}"
      call

      expect(resp['statusDescription']).to eq(expected_status)
    end

    it 'adds status description if from ELB' do
      allow(apigw).to receive(:from_elb?).and_return(false)
      call

      expect(resp['statusDescription']).to be_nil
    end
  end
end
