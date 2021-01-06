require "thor"

module Jets::Commands
  class Main < Base

    class_option :noop, type: :boolean

    desc "build", "Builds and packages project for AWS Lambda"
    long_desc Help.text(:build)
    option :templates, type: :boolean, default: false, desc: "Only build the CloudFormation templates. Skip code building"
    def build
      Build.new(options).run
    end

    desc "configure [TOKEN]", "configure token and updates ~/.jets/config.yml"
    long_desc Help.text(:configure)
    def configure(token=nil)
      Configure.new(options.merge(token: token)).run
    end

    desc "deploy [environment]", "Builds and deploys project to AWS Lambda"
    long_desc Help.text(:deploy)
    # Note the environment is here to trick the Thor parser to allowing an
    # environment parameter. It is not actually set here.  It is set earlier
    # in cli.rb: set_jets_env_from_cli_arg!
    def deploy(environment=nil)
      Deploy.new(options).run
    end

    desc "delete", "Delete the Jets project and all its resources"
    long_desc Help.text(:delete)
    option :yes, aliases: %w[y], type: :boolean, desc: "Skip are you sure prompt."
    option :wait, type: :boolean, default: true, desc: "Wait for stack deletion to complete."
    # Note the environment is here to trick the Thor parser to allowing an
    # environment parameter. It is not actually set here.  It is set earlier
    # in cli.rb: set_jets_env_from_cli_arg!
    def delete(environment=nil)
      Delete.new(options).run
    end

    desc "server", "Runs a local server that mimics API Gateway for development"
    long_desc Help.text(:server)
    option :port, default: "8888", desc: "use PORT"
    option :host, default: "127.0.0.1", desc: "listen on HOST"
    def server
      o = options
      command = "bundle exec rackup --port #{o[:port]} --host #{o[:host]}"
      puts "=> #{command}".color(:green)
      puts Jets::Booter.message
      Jets::Booter.check_config_ru!
      Jets::RackServer.start(options) unless ENV['JETS_RACK'] == '0' # rack server runs in background by default
      Bundler.with_unbundled_env do
        system(command)
      end
    end

    desc "routes", "Print out your application routes"
    long_desc Help.text(:routes)
    def routes
      puts Jets::Router.help(Jets::Router.routes)
      Jets::Router.validate_routes!
    end

    desc "console", "REPL console with Jets environment loaded"
    long_desc Help.text(:console)
    def console
      Console.run
    end

    desc "runner", "Run Ruby code in the context of Jets app non-interactively"
    long_desc Help.text(:runner)
    def runner(code)
      Runner.run(code)
    end

    desc "dbconsole", "Starts DB REPL console"
    long_desc Help.text(:dbconsole)
    def dbconsole
      Dbconsole.start(*args)
    end

    # Command is called 'call' because invoke is a Thor keyword.
    desc "call [function] [event]", "Call a lambda function on AWS or locally"
    long_desc Help.text(:call)
    option :invocation_type, default: "RequestResponse", desc: "RequestResponse, Event, or DryRun"
    option :log_type, default: "Tail", desc: "Works if invocation_type set to RequestResponse"
    option :qualifier, desc: "Lambda function version or alias name"
    option :show_log, type: :boolean, desc: "Shows last 4KB of log in the x-amz-log-result header"
    option :lambda_proxy, type: :boolean, default: true, desc: "Enables automatic Lambda proxy transformation of the event payload"
    option :guess, type: :boolean, default: true, desc: "Enables guess mode. Uses inference to allows use of all dashes to specify functions. Guess mode verifies that the function exists in the code base."
    option :local, type: :boolean, desc: "Enables local mode. Instead of invoke the AWS Lambda function, the method gets called locally with current app code. With local mode guess mode is always used."
    option :retry_limit, type: :numeric, default: nil, desc: "Retry count of invoking function. It work with remote call"
    option :read_timeout, type: :numeric, default: nil, desc: " The number of seconds to wait for response data. It work with remote call"
    def call(function_name, payload='')
      # Printing to stdout can mangle up the response when piping
      # the value to jq. For example:
      #
      #   `jets call --local .. | jq`
      #
      # By redirecting stderr we can use jq safely.
      #
      $stdout.sync = true
      $stderr.sync = true
      $stdout = $stderr # jets call operation
      Call.new(function_name, payload, options).run
    end

    desc "generate [type] [args]", "Generates things like scaffolds"
    long_desc Help.text(:generate) # do use Jets::Generator.help as it'll load Rails const
    def generate(generator, *args)
      Jets::Generator.invoke(generator, *args)
    end

    desc "degenerate [type] [args]", "Destroys things like scaffolds"
    long_desc Help.text(:degenerate) # do use Jets::Generator.help as it'll load Rails const
    def degenerate(generator, *args)
      Jets::Generator.revoke(generator, *args)
    end

    desc "status", "Shows the current status of the Jets app"
    long_desc Help.text(:status)
    def status
      Jets::Cfn::Status.new(options).run
    end

    desc "url", "App url if routes are defined"
    long_desc Help.text(:url)
    def url
      Jets::Commands::Url.new(options).display
    end

    desc "secret", "Generates secret"
    long_desc Help.text(:secret)
    def secret
      puts SecureRandom.hex(64)
    end

    desc "middleware", "Prints list of middleware"
    long_desc Help.text(:middleware)
    def middleware
      stack = Jets.application.middlewares
      stack.middlewares.each do |middleware|
        puts "use #{middleware.name}"
      end
      puts "run #{Jets.application.endpoint}"
    end

    desc "upgrade", "Upgrade Jets"
    long_desc Help.text(:upgrade)
    def upgrade
      Jets::Commands::Upgrade.new(options).run
    end

    desc "version", "Prints Jets version"
    long_desc Help.text(:version)
    def version
      puts Jets.version
    end

    long_desc Help.text(:new)
    Jets::Commands::New.cli_options.each do |args|
      option(*args)
    end
    register(Jets::Commands::New, "new", "new", "Creates a starter skeleton jets project")
  end
end
