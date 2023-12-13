class Jets::CLI::Env
  class Unset < Set
    def run
      are_you_sure?
      puts "Unsetting env vars for #{@lambda_function.name}"

      @lambda_function.environment_variables = environment_variables
      Jets::CLI::Tip.show(:env_change)
    end

    def environment_variables
      @options[:names].each_with_object({}) do |name, hash|
        hash[name] = nil
      end
    end
  end
end
