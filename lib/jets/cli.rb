module Jets
  class CLI < Jets::Thor::Base
    desc "ci SUBCOMMAND", "ci subcommands"
    subcommand "ci", Ci

    desc "concurrency SUBCOMMAND", "concurrency subcommands"
    subcommand "concurrency", Concurrency

    desc "dotenv SUBCOMMAND", "dotenv subcommands"
    subcommand "dotenv", Dotenv

    desc "env SUBCOMMAND", "env subcommands"
    subcommand "env", Env

    desc "generate SUBCOMMAND", "generate subcommands"
    subcommand "generate", Generate

    desc "maintenance SUBCOMMAND", "maintenance subcommands"
    subcommand "maintenance", Maintenance

    desc "package SUBCOMMAND", "package subcommands"
    subcommand "package", Package

    desc "release SUBCOMMAND", "release subcommands"
    subcommand "release", Release

    desc "schedule SUBCOMMAND", "schedule subcommands"
    subcommand "schedule", Schedule

    desc "waf SUBCOMMAND", "waf subcommands"
    subcommand "waf", Waf

    desc "build", "Build deployment"
    option :templates, type: :boolean, desc: "Build only cfn templates. Skip docker build"
    def build
      Build.new(options).run
    end

    desc "bootstrap", "Bootstrap deployment", hide: true
    yes_option
    def bootstrap
      Bootstrap.new(options).run
    end

    desc "clean", "Clean local build folder"
    def clean
      Clean.new(options).run
    end

    desc "deploy", "Deploy stack"
    yes_option
    option :templates, type: :boolean, hide: true, desc: "Deploy only cfn templates. Skip docker build. Experimental option. May be removed."
    def deploy
      Deploy.new(options).run
    end

    desc "delete", "Delete stack"
    yes_option
    def delete
      Delete.new(options).run
    end

    desc "functions", "List functions"
    option :full, default: false, type: :boolean, desc: "Show full function names with the project namespace"
    def functions
      Functions.new(options).run
    end
    map "funs" => :functions
    # use string "funs", otherwise `jets fun` results in Thor sort error

    Init.cli_options.each { |args| option(*args) }
    register(Init, "init", "init", "Initialize project for Jets")

    desc "ping", "Ping", hide: true
    def ping
      Ping.new(options).run
    end

    desc "projects", "List projects"
    paging_options
    format_option(default: "space")
    def projects
      Projects.new(options).run
    end

    desc "login [TOKEN]", "login"
    def login(token = nil)
      Login.new(options.merge(token: token)).run
    end

    desc "logout", "logout"
    def logout
      Logout.new(options).run
    end

    desc "logs", "Tail the logs"
    option :since, desc: "From what time to begin displaying logs.  By default, logs will be displayed starting from 10m in the past. The value provided can be an ISO 8601 timestamp or a relative time. Examples: 10m 2d 2w"
    option :follow, aliases: :f, default: false, type: :boolean, desc: " Whether to continuously poll for new logs. To exit from this mode, use Control-C."
    option :format, default: "plain", desc: "The format to display the logs. IE: detailed, short, plain.  For plain, no timestamp are shown."
    option :filter_pattern, desc: "The filter pattern to use. If not provided, all the events are matched"
    # option :log_group_name, aliases: :n, desc: "The log group name.  Default: /aws/lambda/#{Jets.project.namespace}-controller"
    option :log_group_name, aliases: :n, desc: "The log group name.  Default: /aws/lambda/NAMESPACE-controller"
    option :refresh_rate, default: 1, type: :numeric, desc: "How often to refresh the logs in seconds."
    option :wait_exists, default: true, type: :boolean, desc: "Whether to wait until the log group exists.  By default, it will wait."
    def logs
      Logs.new(options).run
    end

    desc "call", "Call Lambda function"
    function_name_option
    verbose_option
    option :event, aliases: :e, default: "{}", desc: "JSON event to provide to Lambda function as input"
    option :invocation_type, aliases: :t, default: "RequestResponse", desc: "Invocation type.  IE: RequestResponse, Event, DryRun"
    def call
      $stdout.sync = $stderr.sync = true
      $stdout = $stderr
      Call.new(options).run
    rescue Jets::CLI::Call::Error => e
      puts "ERROR: #{e.message}".color(:red)
      abort "Unable to find the function.  Please check the function name and try again."
    end

    desc "curl PATH", "Curl Lambda function"
    function_name_option
    verbose_option
    option :request, aliases: :X, default: "GET", desc: "HTTP request method. IE: GET, POST, PUT, DELETE, etc. Default: GET"
    option :data, aliases: :d, desc: "HTTP request data. The @ character is used to read data from a file. IE: @data.json"
    option :headers, aliases: :H, default: {}, type: :hash, desc: "HTTP request header. IE: -H 'Content-Type: application/json'"
    option :cookie, aliases: :b, desc: "HTTP request cookie. IE: -b 'yummy_cookie=choco; tasty_cookie=strawberry'. If no '=' is used, it is treated as a file with the name of the cookie"
    option :cookie_jar, aliases: :c, desc: "HTTP request cookie jar. IE: -c cookie.jar"
    option :trim, aliases: :t, default: nil, type: :boolean, desc: "Trim large values in the response"
    def curl(path)
      Curl.new(options.merge(path: path)).run
    end

    desc "exec", "REPL or execute commands on AWS Lambda"
    function_name_option
    verbose_option
    def exec(*command)
      Exec.new(options.merge(command: command)).run
    end

    # Shorthand command for jets release:rollback which works too but is hidden
    desc "rollback VERSION", "Rollback to a previous release"
    option :yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"
    def rollback(version)
      Jets::CLI::Release::Rollback.new(options.merge(version: version)).run
    end

    desc "stacks", "List deployed stacks"
    paging_options
    option :all_projects, desc: "Show all stacks across all projects", type: :boolean, default: false
    format_option(default: "space")
    def stacks
      Stacks.new(options).run
    end

    desc "stop", "Stops the deploy"
    yes_option
    def stop
      Stop.new(options).run
    end

    # Normally should not have to use this. This is why it's hidden.
    # Only useful if some reason the remote delete leaves remaining resources behind.
    desc "teardown", "Teardown stack", hide: true
    yes_option
    def teardown
      warn "WARN: You should use `jets delete` instead of `jets teardown`".color(:yellow)
      warn "This is for debugging and will not delete the Jets API deployment record"
      Teardown.new(options).run
    end

    desc "url", "App url"
    format_option(default: "space")
    def url
      Url.new(options).run
    end

    desc "version", "Prints version"
    def version
      puts "Jets #{VERSION}"
    end
  end
end
