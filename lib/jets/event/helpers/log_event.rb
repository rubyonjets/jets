require "base64"
require "json"
require "stringio"
require "zlib"

module Jets::Event::Helpers
  module LogEvent
    def log_event
      encoded = event["awslogs"]["data"]
      compressed_string = Base64.decode64(encoded)
      gz = Zlib::GzipReader.new(StringIO.new(compressed_string))
      uncompressed_string = gz.read
      data = JSON.load(uncompressed_string)
      ActiveSupport::HashWithIndifferentAccess.new(data)
    end

    def log_event?
      !!event.dig("awslogs", "data")
    end
  end
end
