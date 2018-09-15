class Jets::Stack
  class Parameter
    module Dsl
      extend ActiveSupport::Concern
      extend Memoist

      def parameters
        add_common_parameters
        add_depends_on_parameters
        Parameter.definitions(self.class)
      end

      def add_common_parameters
        self.class.parameter(:iam_role)
        self.class.parameter(:s3_bucket)
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
        dependency.to_s.classify.constantize.output_keys
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
