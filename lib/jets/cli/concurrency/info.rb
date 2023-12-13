class Jets::CLI::Concurrency
  class Info < Base
    include Jets::CLI::Lambda::Functions

    def run
      concurrency_info
      account_limit_info
    end

    def concurrency_info
      warn "Concurrency for #{Jets.project.namespace}"

      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "No Lambda Functions found"
      presenter.header = ["Function"]
      presenter.header << "Reserved" if has_reserved?
      presenter.header << "Provisioned" if has_provisioned?
      concurrency_settings.each do |function_name, concurrency_info|
        row = []
        row << function_name.gsub("#{Jets.project.namespace}-", "")
        if has_reserved?
          reserved = concurrency_info[:reserved_concurrency]
          @reserved_concurrency_total ||= 0
          @reserved_concurrency_total += reserved.to_i
          row << reserved
        end
        if has_provisioned?
          provisioned = concurrency_info[:provisioned_concurrency]
          @provisioned_concurrency_total ||= 0
          @provisioned_concurrency_total += provisioned.to_i
          row << provisioned
        end
        presenter.rows << row
      end

      # Totals row
      unless presenter.rows.empty?
        totals = ["total"]
        totals << @reserved_concurrency_total if @reserved_concurrency_total
        totals << @provisioned_concurrency_total if @provisioned_concurrency_total
        presenter.rows << totals
      end
      presenter.show
    end

    def concurrency_settings
      concurrency_settings = {}

      lambda_functions.each do |lambda_function|
        concurrency_info = {
          reserved_concurrency: lambda_function.reserved_concurrency,
          provisioned_concurrency: lambda_function.provisioned_concurrency
        }
        concurrency_info.delete_if { |_, v| v.nil? }
        concurrency_settings[lambda_function.name] = concurrency_info
      end

      concurrency_settings
    end
    memoize :concurrency_settings

    def has_reserved?
      concurrency_settings.any? { |_, info| info.key?(:reserved_concurrency) }
    end

    def has_provisioned?
      concurrency_settings.any? { |_, info| info.key?(:provisioned_concurrency) }
    end

    def account_limit_info
      message = <<~EOL
        Account Limits
          Concurrent Executions: #{account_limit.concurrent_executions}
          Unreserved Concurrent Executions: #{account_limit.unreserved_concurrent_executions}
      EOL
      if has_unreserved?
        message << "Functions with no reserved limit scale to Unreserved Concurrent Executions\n"
      end
      warn message
    end

    def has_unreserved?
      concurrency_settings.any? { |_, info| !info.key?(:reserved_concurrency) }
    end
  end
end
