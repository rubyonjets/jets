class Jets::CLI::Exec
  class Command < Jets::CLI::Call
    # override behavior
    def run
      result = invoke
      if result["errorMessage"]
        # Note:
        # errorType is Function<Errno::ENOENT> and not useful
        # stackTrace is also not useful. IE: [{}, {}, {}, {}, {}, {}, {}]
        # Actual stackTrace only shows up in the logs
        log.error "ERROR: #{result["errorMessage"]}".color(:red)
        useless_stacktrace = result["stackTrace"]&.all? { |line| line == {} }
        if useless_stacktrace
          # Logs can come from:
          #
          #   1. Lambda invoke host log: shows cold-start and Jets.boot errors
          #   2. Lambda runtime container log: shows errors inside handler
          #
          # The result seems to hide the cold-start/Jets.boot errors.
          # Guessing AWS does this for security reasons and hides it with {}.
          #
          # Since result["stackTrace"] since only shows errors within the handler.
          # Errors that outside the handler at cold-start/Jets.boot time are not in
          # result["stackTrace"]. They show up in the logs though.
          # So we show the logs that are available from the header.
          log_last_4kb(<<~EOL)
            Showing last 4KB of logs from x-amz-log-result header for errors.

            You can check for more logs with.

                jets logs -n #{friendly_function_name}

            Last 4KB of logs:
          EOL
        elsif result["stackTrace"]
          log.error "Stack Trace:"
          result["stackTrace"].each do |line|
            log.error line
          end
        else # fallback to errorMessage
          # No stack trace available.
          # Example: result: {"errorMessage"=>"2024-04-18T19:42:51.819Z cdbcd9f2-6d25-4672-8a83-676643698fa0 Task timed out after 3.05 seconds"}
          log.error "errorMessage: #{result["errorMessage"]}"
        end
      else
        $stdout.print result["stdout"]
        $stderr.print result["stderr"] # same as $stderr.puts
      end
      result
    end

    def friendly_function_name
      function_name.sub("#{Jets.project.namespace}-", "")
    end

    # interface method
    def payload
      {command: @options[:command]}.to_json
    end
  end
end
