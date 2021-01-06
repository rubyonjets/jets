require "base64"
require "json"

class Jets::Commands::Call
  include Jets::AwsServices

  def initialize(provided_function_name, event, options={})
    @options = options
    @guess = @options[:guess].nil? ? true : @options[:guess]

    @provided_function_name = provided_function_name
    @event = event

    @invocation_type = options[:invocation_type] || "RequestResponse"
    @log_type = options[:log_type] || "Tail"
    @qualifier = @qualifier
  end

  def function_name
    if @guess
      ensure_guesses_found! # possibly exits here
      guesser.function_name # guesser adds namespace already
    else
      [Jets.config.project_namespace, @provided_function_name].join('-')
    end
  end

  def run
    @options[:local] ? local_run : remote_run
  end

  # With local mode there is no way to bypass the guesser
  def local_run
    puts "Local mode enabled!"
    ensure_guesses_found! # possibly exits here
    klass = guesser.class_name.constantize
    # Example:
    #   PostsController.process(event, context, meth)
    event = JSON.load(transformed_event) || {} # transformed_event is JSON text String

    fun = Jets::PolyFun.new(klass, guesser.method_name)
    result = fun.run(event) # check the logs for polymorphic function errors
    # Note: even though data might not always be json, the JSON.dump does a
    # good job of not bombing, so always calling it to simplify code.

    text = Jets::Util.normalize_result(result)
    STDOUT.puts text
  end

  def remote_run
    puts "Calling lambda function #{function_name} on AWS" unless @options[:mute]
    return if @options[:noop]

    options = {
      # client_context: client_context,
      function_name: function_name,
      invocation_type: @invocation_type, # "Event", # RequestResponse
      log_type: @log_type, # pretty sweet
      payload: transformed_event, # "fileb://file-path/input.json", <= JSON
      qualifier: @qualifier, # "1",
    }

    begin
      resp = lambda_client.invoke(options)
    rescue Aws::Lambda::Errors::ResourceNotFoundException
      puts "The function #{function_name} was not found.  Maybe check the spelling or the AWS_PROFILE?".color(:red)
      return
    end

    if @options[:show_log]
      puts "Last 4KB of log in the x-amz-log-result header:".color(:green)
      puts Base64.decode64(resp.log_result)
    end

    add_console_link_to_clipboard
    result = resp.payload.read # already been normalized/JSON.dump by AWS
    unless @options[:mute_output]
      STDOUT.puts result # only thing that goes to stdout
    end
  end

  def guesser
    @guesser ||= Guesser.new(@provided_function_name)
  end

  def ensure_guesses_found!
    unless guesser.class_name and guesser.method_name
      puts guesser.error_message
      exit
    end
  end

  # @event is String because it can be the file:// notation
  # Returns text String for the lambda.invoke payload.
  def transformed_event
    text = @event
    if text && text.include?("file://")
      text = load_event_from_file(text)
    end

    check_valid_json!(text)

    puts "Function name: #{function_name.color(:green)}" unless @options[:mute]
    return text unless function_name.include?("_controller-")
    return text if @options[:lambda_proxy] == false

    event = JSON.load(text)
    lambda_proxy = {"queryStringParameters" => event}
    JSON.dump(lambda_proxy)
  end

  def load_event_from_file(text)
    path = text.gsub('file://','')
    path = "#{Jets.root}/#{path}" unless path[0..0] == '/'
    unless File.exist?(path)
      puts "File #{path} does not exist.  Are you sure the file exists?".color(:red)
      exit
    end
    text = IO.read(path)
  end

  # Exits with friendly error message when user provides bad just
  def check_valid_json!(text)
    JSON.load(text)
  rescue JSON::ParserError => e
    puts "Invalid json provided:\n  '#{text}'"
    puts "Exiting... Please try again and provide valid json."
    exit 1
  end

  # So use can quickly paste this into their browser if they want to see the function
  # via the Lambda console
  def add_console_link_to_clipboard
    return unless RUBY_PLATFORM =~ /darwin/
    return unless system("type pbcopy > /dev/null")

    # TODO: for add_console_link_to_clipboard get the region from the ~/.aws/config and AWS_PROFILE setting
    region = Aws::S3::Client.new.config.region || ENV["AWS_REGION"] ||'us-east-1'
    link = "https://console.aws.amazon.com/lambda/home?region=#{region}#/functions/#{function_name}?tab=configuration"
    system("echo #{link} | pbcopy")
    puts "Pro tip: The Lambda Console Link to the #{function_name} function has been added to your clipboard." unless @options[:mute]
  end

  # TODO: Hook client_context up and make sure it works. Think I've figure out how to sign client_context below.
  # Client context must be a valid Base64-encoded JSON object
  # Example: http://docs.aws.amazon.com/mobileanalytics/latest/ug/PutEvents.html
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

  # For this class redirect puts to stderr so user can pipe output to tools like
  # jq. Example:
  #   jets call posts_controller-index '{"test":1}' | jq .
  def puts(text)
    $stderr.puts(text)
  end

  def lambda_client
    opt = {}
    opt = opt.merge({retry_limit: @options[:retry_limit]}) if @options[:retry_limit].present?
    opt = opt.merge({http_read_timeout: @options[:read_timeout]}) if @options[:read_timeout].present?

    if opt.empty?
      aws_lambda
    else
      Aws::Lambda::Client.new(opt)
    end
  end

end
