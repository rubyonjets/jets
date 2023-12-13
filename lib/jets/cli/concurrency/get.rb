class Jets::CLI::Concurrency
  class Get < Base
    def initialize(options = {})
      super
      function_name = Jets::CLI::Lambda::Lookup.function(@options[:function])
      @lambda_function = Jets::CLI::Lambda::Function.new(function_name)
    end

    def run
      puts <<~EOL
        Settings for Function: #{@lambda_function.name}
        Reserved concurreny: #{reserved_concurrency}
        Provisioned concurrency: #{provisioned_concurrency}
      EOL
    end

    def provisioned_concurrency
      info = @lambda_function.provisioned_concurrency_info

      if @lambda_function.provisioned_concurrency.nil?
        "not set"
      elsif info[:status] == "IN_PROGRESS"
        "#{info[:allocated]}/#{info[:requested]} (In progress)"
      else
        @lambda_function.provisioned_concurrency
      end
    end

    def reserved_concurrency
      if @lambda_function.reserved_concurrency.nil?
        "not set. Will scale to unreserved limit: #{account_limit.unreserved_concurrent_executions}"
      else
        @lambda_function.reserved_concurrency
      end
    end
  end
end
