require "json"

# Jets::Lambda::Functions represents a collection of Lambda functions.
#
# Jets::Lambda::Functions is the superclass of:
#   Jets::Event::Base
module Jets::Lambda
  class Functions
    include Jets::ExceptionReporting
    include Jets::Util::Logging

    attr_reader :event, :context, :meth
    def initialize(event, context, meth)
      @event = HashWithIndifferentAccess.new(event) # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
      @meth = meth # useful to identify which template to use later.
    end

    include Dsl # At the end so methods like event, context and method
    # do not trigger method_added

    # Pretty hacky since action_view/rendering.rb _normalize_options calls super
    def _normalize_options(options) # :doc:
      options
    end

    class << self
      include Jets::Util::Logging

      attr_reader :abstract
      alias_method :abstract?, :abstract
      @abstract = true

      def inherited(base)
        super
        subclasses << base if base.name
      end

      # Define a controller as abstract. See internal_methods for more details.
      def abstract!
        @abstract = true
      end

      def _prefixes
        []
      end

      # Tracking subclasses because it helps with Lambda::Dsl#find_all_definitions
      def subclasses
        @subclasses ||= []
      end

      # Needed for depends_on. Got added due to stagger logic.
      def output_keys
        []
      end
    end
  end
end
