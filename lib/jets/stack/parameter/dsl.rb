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
          dependency_outputs(dependency).each do |output|
            self.class.parameter(output)
          end
        end if depends_on
      end
      memoize :add_depends_on_parameters # only run once

      # >> Custom.new.outputs
      # => [#<Jets::Stack::Output:0x0000564048f68928 @subclass="Custom", @definition=[:billing_alarm]>, #<Jets::Stack::Output:0x0000564048f63f90 @subclass="Custom", @definition=[:billing_notification]>]
      # >> Custom.new.outputs.map(&:template)
      # => [{"BillingAlarm"=>{"Value"=>"!Ref BillingAlarm"}}, {"BillingNotification"=>{"Value"=>"!Ref BillingNotification"}}]
      # >> Custom.new.outputs.map(&:template).map {|o| o.keys.first}
      # => ["BillingAlarm", "BillingNotification"]
      # >>
      def dependency_outputs(dependency)
        dependency_class = dependency.to_s.classify.constantize
        dependency_class.new.outputs.map(&:template).map {|o| o.keys.first}
      end

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
