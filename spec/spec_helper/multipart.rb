require 'base64'

module Helpers
  module Multipart
    extend Memoist

    def multipart_event(name, base64: false)
      boundary = multipart_boundary(name)
      # Example content-type: "multipart/form-data; boundary=----WebKitFormBoundaryB78dBBqs2MSBKMoX",
      content_type = "multipart/form-data; boundary=#{boundary}"
      body = multipart_fixture(name)
      body = Base64.encode64(body) if base64
      {
        "body" => body,
        "headers" => {
          "Content-Type"=> content_type,
        },
        "isBase64Encoded" => base64,
      }
    end

    def multipart_boundary(name)
      multipart_fixture(name).split("\n").first.strip[2..-1] # also remove firs two chars "--"
    end

    def multipart_fixture(name)
      File.open("spec/fixtures/multipart/#{name}", "rb").read
    end
    memoize :multipart_fixture
  end
end
