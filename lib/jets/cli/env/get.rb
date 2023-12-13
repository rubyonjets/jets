class Jets::CLI::Env
  class Get < Base
    def run
      @lambda_function.environment_variables.find do |key, value|
        if key == @options[:key]
          puts value
          exit # success
        end
      end
      exit 1 # not found
    end
  end
end
