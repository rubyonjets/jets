module Jets::Job::Dsl
  module CloudwatchEvent
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
      with_fresh_properties(multiple_resources: false) do
        props = props.merge(schedule_expression: expression)
        associated_properties(props)
        resource(events_rule_definition) # add associated resource immediately
      end
    end

    def event_pattern(details={}, props={})
      with_fresh_properties(multiple_resources: false) do
        props = props.merge(event_pattern: details)
        associated_properties(props)
        resource(events_rule_definition) # add associated resource immediately
      end
      add_descriptions # useful: generic description in the Event Rule console
    end

    def events_rule(props={})
      with_fresh_properties(multiple_resources: false) do
        associated_properties(props)
        resource(events_rule_definition) # add associated resource immediately
      end
    end

    # Works with eager definitions
    def add_descriptions
      numbered_resources = []
      n = 1
      @associated_resources.map do |associated|
        # definition = associated.definition
        # puts "associated #{associated.inspect}"
        # puts "definition #{definition.inspect}"

        # logical_id = definition.keys.first
        # attributes = definition.values.first

        logical_id = associated.logical_id
        attributes = associated.attributes

        attributes[:properties][:description] ||= "#{self.name} Event Rule #{n}"
        new_definition = { "#{logical_id}" => attributes }
        numbered_resources << Jets::Resource::Associated.new(new_definition)
        n += 1
      end
      @associated_resources = numbered_resources
    end

    def events_rule_definition
      resource = Jets::Resource::Events::Rule.new(associated_properties)
      resource.definition # returns a definition to be added by associated_resources
    end
  end
end