class Jets::CLI::Env
  class Set < Base
    include Parse

    def run
      are_you_sure?
      puts "Setting env vars for #{@lambda_function.name}"

      @lambda_function.environment_variables = environment_variables
      Jets::CLI::Tip.show(:env_change)
    end

    def environment_variables
      parse_cli_env_values(@options[:values])
    end

    def are_you_sure?
      name = self.class.to_s.demodulize.underscore.humanize.downcase
      sure? <<~EOL
        Will #{name} env vars for #{@lambda_function.name}
        The Lambda Function will immediately use the new env vars.
      EOL
    end
  end
end
