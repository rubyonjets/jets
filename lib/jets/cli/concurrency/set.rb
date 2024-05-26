class Jets::CLI::Concurrency
  class Set < Get
    def run
      sure? "Will update the concurrency settings for #{@lambda_function.name}"
      puts "Updating concurrency settings for #{@lambda_function.name}"

      if @options[:reserved]
        @lambda_function.reserved_concurrency = @options[:reserved]
        puts "Set reserved concurrency to #{@options[:reserved]}"
      end

      if @options[:provisioned]
        success = set_provisioned_concurrency(@options[:provisioned])
        puts "Set provisioned concurrency to #{@options[:provisioned]}" if success
      end

      Jets::CLI::Tip.show(:concurrency_change)
    end

    def set_provisioned_concurrency(value)
      @lambda_function.provisioned_concurrency = value
      true # success
    rescue Aws::Lambda::Errors::ResourceNotFoundException => e
      # Can happen for Events Lambda Lambda Functions where Wersion and Alias resources are only created when specified in config/jets
      # For controller Lambda Function the Alias and Version resource is always created.
      if e.message.include?("Cannot find alias")
        puts "ERROR: The live alias does not exist for the function. Please deploy the function an initial provisioned concurrency first.".color(:red)
      end
    end
  end
end
