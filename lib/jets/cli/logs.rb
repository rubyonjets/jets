require "aws-logs"

class Jets::CLI
  class Logs < Base
    include Jets::AwsServices::AwsHelpers

    def run
      options = @options.dup # so it can be modified
      options[:log_group_name] = log_group_name
      options[:since] ||= "10m" # by default, start search 10m in the past
      options[:wait_exists_retries] = 60 # 300 seconds = 300 / 5 = 60 retries
      options[:wait_exists_seconds] = 5

      verb = options[:follow] ? "Tailing" : "Showing"
      warn "#{verb} logs for #{options[:log_group_name]}"

      tail = AwsLogs::Tail.new(options)
      tail.run
    end

    def log_group_name
      log_group_name = @options[:log_group_name] # can be nil
      if log_group_name.nil?
        begin
          log_group_name = Jets::CLI::Lambda::Lookup.function("controller") # function_name
        rescue Jets::CLI::Call::Error => e
          puts "ERROR: #{e.message}"
          abort "Unable to determine log group name by looking it up. Can you double check it?"
        end
      end
      unless log_group_name.include?(Jets.project.namespace)
        log_group_name = "#{Jets.project.namespace}-#{log_group_name}"
      end
      unless log_group_name.include?("aws/lambda")
        log_group_name = "/aws/lambda/#{log_group_name}"
      end
      log_group_name
    end
  end
end
