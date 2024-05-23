class Jets::CLI::Dotenv
  class Set < Base
    include Jets::CLI::Env::Parse

    def run
      sure? sure_message
      puts "Setting SSM vars for #{Jets.project.namespace}"

      perform # interface method
      Jets::CLI::Tip.show(:ssm_change)
    end

    def perform
      ssm_manager.set(vars)
    end

    def vars
      parse_cli_env_values(@options[option_key])
    end

    # interface method
    def option_key
      :values
    end

    def ssm_method
      name = self.class.name.demodulize # Set or Unset
      (name == "Set") ? :set : :delete
    end

    def names
      vars.keys.map(&:to_s)
    end

    def sure_message
      <<~EOL
        Will #{ssm_method} the SSM vars for #{Jets.project.namespace}
        Note: SSM changes do not update the Lambda function env vars.
        You will need run jets deploy to update the env vars.

        #{ssm_manager.preview_list(names)}
      EOL
    end

    def ssm_manager
      Jets::CLI::Dotenv::Ssm.new(@options)
    end
    memoize :ssm_manager
  end
end
