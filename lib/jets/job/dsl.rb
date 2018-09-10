# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        associated_properties(schedule_expression: "rate(#{expression})")
      end

      def cron(expression)
        associated_properties(schedule_expression: "cron(#{expression})")
      end

      def event_pattern(details={})
        associated_properties(event_pattern: details)
        # TODO: FIGURE OUT HOW TO HANDLE MULTIPLE EVENT RULES
        event_rule # think this will do it
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

      def default_associated_resource
        event_rule
      end

      def event_rule
        resource = Jets::Resource::Events::Rule.new(associated_properties)
        resource.definition # returns a definition to be added by associated_resources

        # TODO: FIGURE OUT HOW TO HANDLE MULTIPLE ASSOCIATED RESOURCES COUNTER
        # add_logical_id_counter if @associated_resources.size > 1
        # @associated_resources.last
      end

      # Loop back through the resources and add a counter to the end of the id
      # to handle multiple events.
      # Then replace @associated_resources entirely
      # def add_logical_id_counter
      #   numbered_resources = []
      #   n = 1
      #   @associated_resources.map do |definition|
      #     logical_id = definition.keys.first
      #     logical_id = logical_id.sub(/\d+$/,'')
      #     numbered_resources << { "#{logical_id}#{n}" => definition.values.first }
      #     n += 1
      #   end
      #   @associated_resources = numbered_resources
      # end
    end
  end
end
