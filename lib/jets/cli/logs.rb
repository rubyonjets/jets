require "aws-logs"

class Jets::CLI
  class Logs < Base
    def run
      options = @options.dup # so it can be modified
      options[:log_group_name] = log_group_name
      options[:since] ||= "10m" # by default, start search 10m in the past
      options[:wait_exists_retries] = 60 # 300 seconds = 300 / 5 = 60 retries
      options[:wait_exists_seconds] = 5

      verb = options[:follow] ? "Tailing" : "Showing"
      warn "#{verb} logs for #{log_group_name}"

      tail = AwsLogs::Tail.new(options)
      tail.run
    end

    def log_group_name
      log_group_name = @options[:log_group_name] # can be nil
      return log_group_name if log_group_name

      klass = "Jets::CLI::Logs::#{deploy_type.to_s.camelize}".constantize
      strategy = klass.new(options)
      strategy.log_group_name
    end
  end
end
