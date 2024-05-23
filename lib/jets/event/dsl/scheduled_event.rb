module Jets::Event::Dsl
  module ScheduledEvent
    include RateExpression
    # Public: Creates CloudWatch Event Rule
    #
    # expression - The rate expression.
    #
    # Examples
    #
    #   rate("10 minutes")
    #   rate("10 minutes", description: "Hard event")
    #
    def rate(expression, props = {})
      expression = rate_expression(expression) # normalize the rate expression
      md = expression.match(/\d+\s+\w+/)
      raise ArgumentError, "Invalid rate expression: #{expression}" unless md

      expression = "rate(#{expression})"
      scheduled_event(expression, props)
    end

    # Public: Creates CloudWatch Event Rule
    #
    # expression - The cron expression.
    #
    # Examples
    #
    #   cron("0 */12 * * ? *")
    #   cron("0 */12 * * ? *", description: "Hard event")
    #
    def cron(expression, props = {})
      expression = normalize_cron_expression(expression)
      scheduled_event("cron(#{expression})", props)
    end

    def normalize_cron_expression(expr)
      parts = expr.split(" ")
      # AWS Cron expressions require ? for the day of the week field
      parts[-2] = "?" if parts[-2] == "*"
      parts.join(" ")
    end

    def scheduled_event(expression, props = {})
      props = props.merge(ScheduleExpression: expression)
      rule_event(props)
    end

    # interface method
    def rule_event(props = {})
      {}
    end
  end
end
