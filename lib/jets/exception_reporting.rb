module Jets
  module ExceptionReporting
    extend ActiveSupport::Concern

    delegate :with_exception_reporting, to: :class
    module ClassMethods
      def with_exception_reporting
        yield
      rescue => exception
        Jets.report_exception(exception)
        decorate_with_exception_reported(exception)
        raise
      end

      # We decorate the exception with a with_exception_reported? method so we
      # can use it the MainProcessor rescue Exception handling to not
      # double report the exception and only reraise.
      #
      # If we have properly rescue all exceptions then this would not be needed.
      # However, we're being paranoid also by rescuing Exception in the MainProcessor.
      #
      # Also, in general, it's hard to follow Exception bubbling logic. This
      # approach allows us to not have to worry about bubbling and call
      # with_exception_reporting indiscriminately.
      def decorate_with_exception_reported(exception)
        unless exception.respond_to?(:with_exception_reported?)
          exception.define_singleton_method(:with_exception_reported?) { true }
        end
      end
    end

    module Process
      extend ActiveSupport::Concern
      module ClassMethods
        def process(event, context, meth)
          with_exception_reporting do
            super
          end
        end
      end
    end
  end
end
