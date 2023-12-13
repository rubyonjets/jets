require "action_dispatch/http/mime_type"

describe Jets::Shim::Response::Lambda do
  let :response do
    described_class.new(triplet)
  end

  describe "apigw" do
    let :triplet do
      [
        200,
        {"Content-Type" => "application/json; charset=utf-8"},
        ["body"]
      ]
    end

    it "has apigw structure" do
      h = response.translate
      expect(h.keys.size).to eq 4
      expect(h.keys.sort).to eq [:body, :headers, :isBase64Encoded, :statusCode]
    end

    # "response set-cookies"
    # https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-cookies
    context "cookies" do
      let :triplet do
        [
          200,
          headers,
          ["body"]
        ]
      end
      let :headers do
        {
          "Content-Type" => "text/html; charset=utf-8",
          "Set-Cookie" => set_cookie
        }
      end

      context "set_cookie is String" do
        let :set_cookie do
          "yummy1=value1"
        end

        it "for single cookie" do
          h = response.translate
          expect(h[:statusCode]).to eq 200
          expect(h[:headers]).to include("Content-Type" => "text/html; charset=utf-8")
          expect(h[:headers]).to_not have_key("Set-Cookie")
          expect(h[:body]).to eq Base64.strict_encode64("body")
          expect(h[:cookies]).to eq ["yummy1=value1"]
        end
      end

      context "set_cookie is Array" do
        let :set_cookie do
          [
            "yummy1=value1",
            "yummy2=value2"
          ]
        end

        it "for multiple cookies" do
          h = response.translate
          expect(h[:statusCode]).to eq 200
          expect(h[:headers]).to include("Content-Type" => "text/html; charset=utf-8")
          expect(h[:headers]).to_not have_key("Set-Cookie")
          expect(h[:body]).to eq Base64.strict_encode64("body")
          expect(h[:cookies]).to eq ["yummy1=value1", "yummy2=value2"]
        end
      end
    end

    # Note: Rails returns MimeType objects. APIGW requires strings.
    context "Rails" do
      let :triplet do
        [
          200,
          {"Content-Type" => content_type},
          ["body"]
        ]
      end

      context "content_type is application/json object" do
        let :content_type do
          Mime::Type.lookup "application/json" # => object
        end

        it "translate to String" do
          h = response.translate
          expect(h[:statusCode]).to eq 200
          expect(h[:headers]).to include("Content-Type" => "application/json")
          expect(h[:body]).to eq Base64.strict_encode64("body")
        end
      end

      context "content_type is text/html object" do
        let :content_type do
          Mime::Type.lookup "text/html" # => object
        end

        it "translate to String" do
          h = response.translate
          expect(h[:statusCode]).to eq 200
          expect(h[:headers]).to include("Content-Type" => "text/html")
          expect(h[:body]).to eq Base64.strict_encode64("body")
        end
      end
    end
  end
end
