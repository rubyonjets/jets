# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        schedule_job("rate(#{expression})")
      end

      def cron(expression)
        schedule_job("cron(#{expression})")
      end

      def schedule_job(expression)
        associated_properties(schedule_expression: expression)
        associated_resources(event_rule_definition) # add associated resources immediately
        @associated_properties = nil # reset for next one
      end

      def event_pattern(details={})
        associated_properties(event_pattern: details)
        associated_resources(event_rule_definition) # add associated resources immediately
        @associated_properties = nil # reset for next one
        # TODO: FIGURE OUT HOW TO HANDLE DESCRIPTIONS
        # add_descriptions # useful: generic description in the Event Rule console
      end

      # def add_descriptions
      #   numbered_resources = []
      #   n = 1
      #   @associated_resources.map do |definition|
      #     logical_id = definition.keys.first
      #     attributes = definition.values.first
      #     attributes[:properties][:description] = "#{self.name} Event Rule #{n}"
      #     numbered_resources << { "#{logical_id}" => attributes }
      #     n += 1
      #   end
      #   @associated_resources = numbered_resources
      # end

      def default_associated_resource_definition
        event_rule_definition
      end

      def event_rule_definition
        resource = Jets::Resource::Events::Rule.new(associated_properties)
        resource.definition # returns a definition to be added by associated_resources
      end
    end
  end
end
