module Jets::Thor
  class Auth
    def initialize(args)
      @args = args
    end

    # Only check once. Thor subcommands result in 2 calls to Thor dispatch.
    @@success = false
    def check!
      return @@success if @@success
      # Commands that do not require authentication
      return if no_auth_command?

      if api_key?
        resp = ping
        puts resp["message"] unless resp["message"] == "pong"
        @@success = true
      else
        login_help_message
        exit 1
      end
    end

    # interface method
    def api_key?
      Jets::Api::Config.instance.api_key?
    end

    # interface method
    def ping
      Jets::Api::Ping.create
    end

    # Tricky: Thor load the command and then the subcommand.
    # IE: jets generate:event
    #     @args = ["dotenv", "list"] # first pass
    #     @args = ["list"]           # second pass
    # We only check first pass to see if it is a no_auth_command.
    # And cache it so the second pass never occurs.
    @@no_auth_command = nil
    def no_auth_command?
      return @@no_auth_command unless @@no_auth_command.nil?
      base = %w[
        generate
        init
      ]
      more = %w[
        ci:info
        ci:init
        ci:logs
        ci:start
        ci:status
        ci:stop
        clean
        concurrency
        curl
        dotenv
        env
        exec
        functions
        funs
        logs
        maintenance
        schedule
        waf:info
        waf:init
      ]
      commands = base + more
      commands += ProjectCheck.new(@args).no_project_commands
      commands.uniq!
      # @args contains the command and subcommand
      # IE: jets ci:init => ["ci", "init"]

      @@no_auth_command = (commands & @args).any? ||  # IE: ["ci"] & ["ci", "init"]
        (commands & [@args.join(":")]).any? ||        # IE: ["ci:init"] & ["ci:init"]
        @args.empty?
    end

    def login_help_message
      puts <<~EOL
        An account is required to use Jets.
        You can sign up at https://www.rubyonjets.com

        Please login. You can login with

            jets login

      EOL
    end

    def handle_unauthorized(e)
      puts "Unauthorized: #{e.message}".color(:red)
      exit 1
    end
  end
end
