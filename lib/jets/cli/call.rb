class Jets::CLI
  class Call
    class Error < StandardError; end

    extend Memoist
    include Jets::AwsServices
    include Jets::Util::Logging

    attr_reader :event
    def initialize(options = {})
      @options = options
      @log_type = options[:log_type] || "Tail"
      @event = options[:event] || "{}" # json string
    end

    def run
      warn "Calling Lambda function #{function_name}"
      result = invoke
      warn "Response:".color(:green)
      # only thing that goes to stdout. so can pipe to commands like jq
      puts JSON.pretty_generate(result)
    end

    def invoke
      params = {
        function_name: function_name,
        invocation_type: invocation_type, # Event or RequestResponse
        log_type: @log_type, # pretty sweet
        payload: payload # json string
        # qualifier: @qualifier # "1", version or alias published version. not used yet
      }

      resp = nil
      begin
        resp = lambda_client.invoke(params)
        # Capture @log_last_4kb for log_last_4kb method
        # log_last_4kb is an interface method used by Exec::Command
        @log_last_4kb = resp.log_result
      rescue Aws::Lambda::Errors::ResourceNotFoundException
        warn "ERROR: function #{function_name} not found".color(:red)
        warn "Maybe check the spelling or the AWS_PROFILE?"
        return resp
      end

      if !/^2/.match?(resp[:status_code].to_s)
        warn "ERROR: Lambda function #{function_name} returned status code: #{resp[:status_code]}".color(:red)
        warn resp
      end

      if verbose? && invocation_type != "Event"
        log_last_4kb
      end

      if invocation_type == "Event"
        resp
      else
        text = resp.payload.read # already been normalized/JSON.dump by AWS
        data = JSON.parse(text)
        ActiveSupport::HashWithIndifferentAccess.new(data)
      end
    end

    # interface method
    def log_last_4kb(header_message = "Showing last 4KB of log from x-amz-log-result header:")
      return unless @log_last_4kb
      warn header_message
      warn Base64.decode64(@log_last_4kb)
    end

    # Event invocation returns a "202 Accepted" response.
    # It means the request has accepted for processing, but the processing has not
    # been completed. Event invocation types are asynchronous.
    # The resp.payload.read is a empty string and is not JSON parseable.
    # We the raw resp object so the caller can inspect the status code and headers.
    # Example:
    #
    #   {
    #     status_code: 202,
    #     function_error: nil,
    #     log_result: nil,
    #     payload: "[FILTERED]",
    #     executed_version: nil
    #   }
    #
    # Event invocation only use by Jets::Preheat.perform
    def invocation_type
      @options[:invocation_type] || "RequestResponse"
    end

    def verbose?
      @options[:verbose] || @options[:logs]
    end

    # payload returns a JSON String for the lambda.invoke payload.
    # It can be the file:// notation
    # interface method
    def payload
      text = @event
      if text&.include?("file://")
        text = load_event_from_file(text)
      end
      text
    end
    memoize :payload

    def load_event_from_file(text)
      path = text.gsub("file://", "")
      path = "#{Jets.root}/#{path}" unless path[0..0] == "/"
      unless File.exist?(path)
        puts "File #{path} does not exist.  Are you sure the file exists?".color(:red)
        exit 1
      end
      text = IO.read(path)
      check_valid_json!(text)
      text
    end

    # Exits with friendly error message when user provides bad just
    def check_valid_json!(text)
      JSON.parse(text)
    rescue JSON::ParserError => e
      puts "Invalid json provided:\n  '#{text}'"
      puts "Exiting... Please try again and provide valid json."
      exit 1
    end

    def function_name
      name = @options[:function] || "controller"
      Jets::CLI::Lambda::Lookup.function(name)
    end
    memoize :function_name
  end
end
