module Jets::Job::Dsl
  module RuleEvent
    # Public: Creates CloudWatch Event Rule
    #
    # expression - The rate expression.
    #
    # Examples
    #
    #   rate("10 minutes")
    #   rate("10 minutes", description: "Hard job")
    #
    def rate(expression, props={})
      schedule_job("rate(#{expression})", props)
    end

    # Public: Creates CloudWatch Event Rule
    #
    # expression - The cron expression.
    #
    # Examples
    #
    #   cron("0 */12 * * ? *")
    #   cron("0 */12 * * ? *", description: "Hard job")
    #
    def cron(expression, props={})
      schedule_job("cron(#{expression})", props)
    end

    def schedule_job(expression, props={})
      props = props.merge(schedule_expression: expression)
      rule_event(props)
    end

    def rule_event(props={})
      if props.key?(:detail)
        description = props.key?(:description) ? props.delete(:description) : rule_description
        rule_props = { event_pattern: props, description: description }
      else # if props.key?(:event_pattern)
        props[:description] ||= rule_description
        rule_props = props
      end

      with_fresh_properties(multiple_resources: false) do
        associated_properties(rule_props)
        resource(events_rule_definition) # add associated resource immediately
      end
    end

    def rule_description
      self.rule_counter += 1
      "#{self.name} event rule #{rule_counter}"
    end

    def events_rule_definition
      resource = Jets::Resource::Events::Rule.new(associated_properties)
      resource.definition # returns a definition to be added by associated_resources
    end
  end
end
