require "active_support"
require "active_support/core_ext/string/filters"

class Jets::CLI::Curl
  class Request < Jets::CLI::Call
    TRIM_MAX = ENV["JETS_CURL_TRIM_MAX"] || 64
    def run
      warn "Calling Lambda function #{function_name}"
      show_body
      result = invoke

      if result[:cookies] && @options[:cookie_jar]
        cookie_jar = Adapter::Cookies::Jar.new(result, @options[:cookie_jar])
        cookie_jar.write_to_file
      end
      if @options[:trim] || ENV["JETS_CURL_TRIM"]
        trim!(result, TRIM_MAX)
      else
        result
      end
    end

    def show_body
      return unless @options[:verbose] && @options[:data]
      hash = JSON.parse(payload)
      body = hash["body"]
      text = begin
        JSON.pretty_generate(JSON.parse(body))
      rescue JSON::ParserError
        body
      end

      warn "Request Body:"
      warn text
    end

    # interface method: override to convert cli curl-like options to Call payload
    def payload
      adapter.convert
    end

    def trim!(hash, max_length)
      hash.transform_values! do |value|
        if value.is_a?(String) && value.length > max_length
          value.truncate(max_length)
        elsif value.is_a?(Hash)
          trim!(value, max_length)
        elsif value.is_a?(Array)
          value.map! { |v| (v.is_a?(String) && v.length > max_length) ? v.truncate(max_length) : v }
        else
          value
        end
      end
    end

    def adapter
      # Only support Lambda URL for now.
      Adapter::Lambda.new(@options)
    end
    memoize :adapter
  end
end
