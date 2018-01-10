# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Rule::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def scope(value)
        properties(scope: value)
      end

      # Override register_task.
      # Creates instances of Rule::Task instead of a Lambda::Task
      def register_task(meth)
        all_tasks[meth] = Jets::Rule::Task.new(self.name, meth,
          properties: @properties)
        true
      end
    end
  end
end
