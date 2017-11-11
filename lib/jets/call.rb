require "base64"
require "json"

class Jets::Call
  include Jets::AwsServices

  def initialize(short_function_name, payload, options)
    @options = options

    @function_name = get_function_name(short_function_name)
    @payload = payload

    @invocation_type = options[:invocation_type] || "RequestResponse"
    @log_type = options[:log_type] || "Tail"
    @qualifier = @qualifier
  end

  def get_function_name(short_function_name)
    [Jets.config.project_namespace, short_function_name].join('-')
  end

  def run
    puts("Calling lambda function on AWS")
    return if @options[:noop]
    resp = lambda.invoke(
      # client_context: client_context,
      function_name: @function_name,
      invocation_type: @invocation_type, # "Event", # RequestResponse
      log_type: @log_type, # pretty sweet
      payload: @payload, # "fileb://file-path/input.json",
      qualifier: @qualifier, # "1",
    )

    pp resp

    # puts "log_result #{resp.log_result}"
    # puts Base64.decode64(resp.log_result)

  end

  # Client context must be a valid Base64-encoded JSON object
  # Example: http://docs.aws.amazon.com/mobileanalytics/latest/ug/PutEvents.html
  # TODO: figure out how to sign client_context
  def client_context
    context = {
      "client" => {
        "client_id" => "Jets",
        "app_title" => "jets call cli",
        "app_version_name" => Jets::VERSION,
      },
      "custom" => {},
      "env" =>{
        "platform" => RUBY_PLATFORM,
        "platform_version" => RUBY_VERSION,
      }
    }
    Base64.encode64(JSON.dump(context))
  end
end
