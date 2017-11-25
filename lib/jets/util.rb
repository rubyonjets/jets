class Jets::Util
  class << self
    # Make sure that the result is a text.  If it is parseable json then
    # dump it as json instead of the raw string that is meant to be json anyway.
    def normalize_result(result)
      if result.is_a?(Hash)
        return JSON.dump(result)
      end

      # If it is json parseable then parse it and dump it as json
      json?(result) ? JSON.dump(result) : result
    end

    # https://stackoverflow.com/questions/26232909/checking-if-a-string-is-valid-json-before-trying-to-parse-it
    def json?(text)
      JSON.parse(text)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end
end
