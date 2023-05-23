require "base64"
require "json"

module Jets::Command
  class CallCommand < Base # :nodoc:
    include Jets::AwsServices

    desc "call [function] [event]", "Call a lambda function on AWS or locally"
    long_desc Help.text(:call)
    option :invocation_type, default: "RequestResponse", desc: "RequestResponse, Event, or DryRun"
    option :log_type, default: "Tail", desc: "Works if invocation_type set to RequestResponse"
    option :qualifier, desc: "Lambda function version or alias name"
    option :show_log, type: :boolean, desc: "Shows last 4KB of log in the x-amz-log-result header"
    option :show_logs, type: :boolean, desc: "Shows last 4KB of log in the x-amz-log-result header"
    option :lambda_proxy, type: :boolean, default: true, desc: "Enables automatic Lambda proxy transformation of the event payload"
    option :guess, type: :boolean, default: true, desc: "Enables guess mode. Uses inference to allows use of all dashes to specify functions. Guess mode verifies that the function exists in the code base."
    option :local, type: :boolean, desc: "Enables local mode. Instead of invoke the AWS Lambda function, the method gets called locally with current app code. With local mode guess mode is always used."
    option :retry_limit, type: :numeric, default: nil, desc: "Retry count of invoking function. It work with remote call"
    option :read_timeout, type: :numeric, default: nil, desc: " The number of seconds to wait for response data. It work with remote call"
    def perform(function_name, payload='')
      $stdout.sync = true
      $stderr.sync = true
      $stdout = $stderr # jets call operation
      Jets::Commands::Call::Caller.new(function_name, payload, options).run
    end
  end
end
