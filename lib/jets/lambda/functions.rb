require 'json'

# Jets::Lambda::Functions represents a collection of Lambda functions.
#
# Jets::Lambda::Functions is the superclass of:
#   Jets::Controller::Base
#   Jets::Job::Base
module Jets::Lambda
  class Functions
    attr_reader :event, :context, :meth
    def initialize(event, context, meth)
      @event = HashWithIndifferentAccess.new(event) # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
      @meth = meth
      # store meth because it is useful to for identifying the which template
      # to use later.
    end

    include Dsl # At the end so methods like event, context and method
      # do not trigger method_added

    class << self
      # Tracking subclasses because it helps with Lambda::Dsl#find_all_tasks
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        super
        self.subclasses << base if base.name
      end

      # Needed for depends_on. Got added due to stagger logic.
      def output_keys
        []
      end
    end
  end
end
