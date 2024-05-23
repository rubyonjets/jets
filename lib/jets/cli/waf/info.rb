class Jets::CLI::Waf
  class Info < Base
    include Jets::AwsServices

    def web_acl_name
      @options[:name] || Jets::CLI::Waf.waf_name
    end

    def run
      ENV["AWS_REGION"] = "us-east-1" # wafv2 only works in us-east-1

      web_acl_summary = web_acl_summaries.find do |i|
        web_acl_name == i.name
      end

      unless web_acl_summary
        puts "Web ACL not found: #{web_acl_name}"
        return
      end

      resp = wafv2.get_web_acl(
        id: web_acl_summary.id,
        name: web_acl_summary.name,
        scope: "CLOUDFRONT"
      )
      web_acl = resp.web_acl
      present(web_acl)
    end

    def web_acl_summaries
      Enumerator.new do |y|
        next_token = :start
        while next_token
          params = {}
          params[:next_token] = next_token if next_token && next_token != :start
          params[:scope] = "CLOUDFRONT"
          resp = wafv2.list_web_acls(params)
          y.yield resp.web_acls # acl summaries
          # Looks like if there's only 1 page next_token is not even availablel
          break unless resp.respond_to?(:next_token)
          next_token = resp.next_token
        end
      end.lazy.flat_map { |i| i }
    end

    private

    def present(web_acl)
      presenter = CliFormat::Presenter.new(@options)
      presenter.empty_message = "Web ACL not found: #{web_acl_name}"

      data = [
        ["Name", web_acl.name],
        ["Description", web_acl.description],
        ["Id", web_acl.id],
        ["Capacity", web_acl.capacity]
      ]
      rules = web_acl.rules.sort_by!(&:priority)

      rules.each_with_index do |rule, i|
        name = rule_name(rule)
        data << ["Rule #{i + 1}", name]
      end

      metric = metric_name(web_acl)
      data << ["Metric", metric] if metric

      # Additional info
      data << ["Logging", logging(web_acl)]
      rules.each do |rule|
        rate_limited_ips(web_acl, rule)
      end

      data.each do |row|
        presenter.rows << row
      end
      presenter.show
    end

    def rule_name(rule)
      override_action = rule.override_action.to_h.keys.first
      action = rule.action.to_h.keys.first

      label = (override_action == :none || override_action.nil?) ? action : override_action
      label ||= :block
      label = :monitoring if label == :count
      "#{rule.name} (#{label})"
    end

    def metric_name(web_acl)
      web_acl&.visibility_config&.metric_name
    end

    def logging(web_acl)
      resp = wafv2.get_logging_configuration(resource_arn: web_acl.arn)
      # log_destination_configs=
      #  ["arn:aws:logs:us-east-1:112233445555:log-group:aws-waf-logs-dev:*"],
      configs = resp.logging_configuration.log_destination_configs
      configs.map! do |config|
        # arn:aws:logs:us-east-1:112233445555:log-group:aws-waf-logs-dev:*
        # only keep everything after the AWS account id which is exactly 12 digits
        c = config.sub(/arn:aws:logs:.*:\d{12}:/, "")
        c.sub(/:\*$/, "") # remove trailing colon
      end
      configs.join(", ")
    rescue Aws::WAFV2::Errors::WAFNonexistentItemException
      "disabled"
    end

    def rate_limited_ips(web_acl, rule)
      return unless rule.statement.rate_based_statement

      resp = wafv2.get_rate_based_statement_managed_keys(
        scope: "CLOUDFRONT",
        web_acl_name: web_acl.name,
        web_acl_id: web_acl.id,
        rule_name: rule.name
      )
      addresses = resp.managed_keys_ipv4.addresses + resp.managed_keys_ipv6.addresses
      return if addresses.empty?

      puts "Rule #{rule.name} rate limited IPs:"
      addresses.each do |address|
        puts "  #{address}"
      end
    end
  end
end
