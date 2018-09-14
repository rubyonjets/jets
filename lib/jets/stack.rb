require 'active_support/concern'

module Jets
  class Stack
    autoload :Definition, 'jets/stack/definition' # Registration and definitions
    autoload :Main, 'jets/stack/main'
    autoload :Parameter, 'jets/stack/parameter'
    autoload :Output, 'jets/stack/output'
    autoload :Resource, 'jets/stack/resource'
    autoload :Builder, 'jets/stack/builder'

    include Main::Dsl
    include Parameter::Dsl
    include Output::Dsl
    include Resource::Dsl

    class << self
      # Track all command subclasses.
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        super
        self.subclasses << base if base.name
      end

      def build?
        # Build it to figure out if we need to build the stack for the
        # SharedBuilder. Pretty funny looking.
        builder = Jets::Stack::Builder.new(new)
        !builder.template.empty?
      end
    end
  end
end
