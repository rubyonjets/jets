class Jets::CLI::Logs
  class Lambda < Base
    def log_group_name
      begin
        log_group_name = Jets::CLI::Lambda::Lookup.function("controller") # function_name
      rescue Jets::CLI::Call::Error => e
        puts "ERROR: #{e.message}"
        abort "Unable to determine log group name by looking it up. Can you double check it?"
      end

      unless log_group_name.include?(parent_stack_name)
        log_group_name = "#{parent_stack_name}-#{log_group_name}"
      end

      unless log_group_name.include?("aws/lambda")
        log_group_name = "/aws/lambda/#{log_group_name}"
      end

      log_group_name
    end
  end
end
