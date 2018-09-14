class Jets::Stack
  class Parameter
    module Dsl
      extend ActiveSupport::Concern
      extend Memoist

      def parameters
        add_depends_on_parameters
        Parameter.definitions(self.class)
      end

      def add_depends_on_parameters
        depends_on = self.class.depends_on
        depends_on.each do |dependency|
          self.class.parameter(dependency)
        end if depends_on
      end
      memoize :add_depends_on_parameters # only run once

      class_methods do
        def parameter(*definition)
          # self is subclass is the stack that inherits from Jets::Stack
          # IE: ExampleStack < Jets::Stack
          Parameter.new(self, *definition).register
        end
      end
    end
  end
end
