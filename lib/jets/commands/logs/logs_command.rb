require "aws-logs"

module Jets::Command
  class LogsCommand < Base # :nodoc:
    include Jets::AwsServices

    option :since, desc: "From what time to begin displaying logs.  By default, logs will be displayed starting from 10m in the past. The value provided can be an ISO 8601 timestamp or a relative time. Examples: 10m 2d 2w"
    option :follow, aliases: :f, default: false, type: :boolean, desc: " Whether to continuously poll for new logs. To exit from this mode, use Control-C."
    option :format, default: "simple", desc: "The format to display the logs. IE: detailed or short.  With detailed, the log stream name is also shown."
    option :filter_pattern, desc: "The filter pattern to use. If not provided, all the events are matched"
    option :log_group_name, aliases: :n, desc: "The log group name.  By default, it is /aws/lambda/#{Jets.project_namespace}-controller"
    option :refresh_rate, default: 1, type: :numeric, desc: "How often to refresh the logs in seconds."
    option :wait_exists, default: true, type: :boolean, desc: "Whether to wait until the log group exists.  By default, it will wait."
    long_desc Help.text(:logs)
    def perform
      show_logs
    end

  private
    def show_logs
      options = @options.dup # so it can be modified
      options[:log_group_name] = log_group_name
      options[:since] ||= "10m" # by default, start search 10m in the past
      options[:wait_exists_retries] = 12 # 12 * 5 = 60 seconds

      verb = options[:follow] ? "Tailing" : "Showing"
      $stderr.puts "#{verb} logs for #{options[:log_group_name]}"

      tail = AwsLogs::Tail.new(options)
      tail.run
    end

    def log_group_name
      default = "/aws/lambda/#{Jets.project_namespace}-controller"
      return default unless @options[:log_group_name]

      if @options[:log_group_name].include?("aws/lambda") || @options[:log_group_name].include?(Jets.project_namespace)
        @options[:log_group_name]
      else
        # IE: hard_job-dig => /aws/lambda/demo-dev-hard_job-dig
        "/aws/lambda/#{Jets.project_namespace}-#{@options[:log_group_name]}"
      end
    end
  end
end
