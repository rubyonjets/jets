class Jets::CLI::Concurrency
  class Unset < Set
    def run
      sure? "Will unset the concurrency settings for #{Jets.project.namespace}"
      puts "Unsetting concurrency settings for #{Jets.project.namespace}"

      if @options[:reserved]
        @lambda_function.reserved_concurrency = nil
        puts "Removed reserved concurrency"
        puts "Will scale to your AWS account unreserved limit. Currently: #{account_limit.unreserved_concurrent_executions}"
      end

      if @options[:provisioned]
        success = set_provisioned_concurrency(0)
        puts "Removed provisioned concurrency" if success
      end

      Jets::CLI::Tip.show(:concurrency_change)
    end
  end
end
