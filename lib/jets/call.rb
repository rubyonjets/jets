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

  # For this class redirect puts to stderr so user can pipe output to tools like
  # jq. Example:
  #   jets call posts-controller-index '{"test":1}' | jq .
  def puts(text)
    $stderr.puts(text)
  end

  def get_function_name(short_function_name)
    [Jets.config.project_namespace, short_function_name].join('-')
  end

  def run
    puts "Calling lambda function #{@function_name} on AWS".colorize(:green)
    return if @options[:noop]

    add_console_link_to_clipboard

    resp = lambda.invoke(
      # client_context: client_context,
      function_name: @function_name,
      invocation_type: @invocation_type, # "Event", # RequestResponse
      log_type: @log_type, # pretty sweet
      payload: @payload, # "fileb://file-path/input.json",
      qualifier: @qualifier, # "1",
    )

    if @options[:show_log]
      puts "Last 4KB of log in the x-amz-log-result header:".colorize(:green)
      puts Base64.decode64(resp.log_result)
    end

    $stdout.puts resp.payload.read # only thing that goes to stdout
  end

  # So use can quickly paste this into their browser if they want to see the function
  # via the Lambda console
  def add_console_link_to_clipboard
    return unless RUBY_PLATFORM =~ /darwin/
    return unless system("type pbcopy > /dev/null")

    region = Aws.config[:region] || 'us-east-1'
    link = "https://console.aws.amazon.com/lambda/home?region=#{region}#/functions/#{@function_name}?tab=configuration"
    system("echo #{link} | pbcopy")
    puts "Pro tip: The Lambda Console Link to the #{@function_name} function has been added to your clipboard."
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
