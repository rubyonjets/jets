require 'json'

# Jets::Lambda::Functions represents a collection of Lambda functions.
#
# Jets::Lambda::Functions is the superclass of:
#   Jets::Controller::Base
#   Jets::Job::Base
module Jets::Lambda
  class Functions
    include Jets::ExceptionReporting

    attr_reader :event, :context, :meth
    def initialize(event, context, meth)
      @event = HashWithIndifferentAccess.new(event) # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
      @meth = meth
      # store meth because it is useful to for identifying the which template
      # to use later.
    end

    def logger
      Jets.logger
    end

    include Dsl # At the end so methods like event, context and method
      # do not trigger method_added

    # Pretty hacky since action_view/rendering.rb _normalize_options calls super
    def _normalize_options(options) # :doc:
      options
    end

    class << self
      attr_reader :abstract
      alias_method :abstract?, :abstract
      @abstract = true

      class << self
        def inherited(klass) # :nodoc:
          # Define the abstract ivar on subclasses so that we don't get
          # uninitialized ivar warnings
          unless klass.instance_variable_defined?(:@abstract)
            klass.instance_variable_set(:@abstract, false)
          end
          super
        end
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
