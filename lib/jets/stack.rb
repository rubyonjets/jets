module Jets
  class Stack
    include Main::Dsl
    include Parameter::Dsl
    include Output::Dsl
    include Resource::Dsl

    class << self
      extend Memoist

      # Track all command subclasses.
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        super
        self.subclasses << base if base.name
      end

      # klass = Jets::Stack.new_class("Bucket3")
      def new_class(class_name, &block)
        # https://stackoverflow.com/questions/4113479/dynamic-class-definition-with-a-class-name
        # Defining the constant this way gets around: SyntaxError: dynamic constant assignment error
        klass = Class.new(Jets::Stack) # First klass is an anonymous class. IE: class.name is nil
        klass = Object.const_set(class_name, klass) # now klass is a named class
        Jets::Stack.subclasses << klass # mimic inherited hook because

        # Must run class_eval after adding to subclasses in order for the resource declarations in the
        # so that the resources get registered to the right subclass.
        klass.class_eval(&block)
        klass # return klass
      end

      # Build it to figure out if we need to build the stack for the SharedBuilder
      def build?
        empty = template == {"Parameters"=>{"IamRole"=>{"Type"=>"String"}, "S3Bucket"=>{"Type"=>"String"}}}
        !empty
      end

      def functions
        stack = new
        # All the & because resources might be nil
        templates = stack.resources&.map(&:template)&.select do |t|
          attributes = t.values.first
          attributes['Type'] == 'AWS::Lambda::Function'
        end
        templates ||= []
        templates.map { |t| Function.new(t) }
      end

      def template
        # Pretty funny looking, creating an instance of stack to be passed to the Builder.
        # Another way of looking at it:
        #
        #   stack = new # MyStack.new
        #   builder = Jets::Stack::Builder.new(stack)
        #
        builder = Jets::Stack::Builder.new(new)
        builder.template
      end
      memoize :template

      def lookup(logical_id)
        looker.output(logical_id)
      end

      def looker
        Jets::Stack::Output::Lookup.new(self)
      end
      memoize :looker

      def output_keys
        outputs = new.outputs || []
        outputs.map(&:template).map {|o| o.keys.first}
      end
    end
  end
end
