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
      extend Memoist

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
        # !builder.template.empty?
        empty = builder.template == {"Parameters"=>{"IamRole"=>{"Type"=>"String"}, "S3Bucket"=>{"Type"=>"String"}}}
        !empty
      end

      def has_resources?
        !subclasses.empty?
      end

      # Usage:
      #
      #   Jets::Stack.has_resources?
      #
      def has_resources?
        # need to eager load the app/shared resources in order to check if shared resources have been registered
        eager_load_shared_resources!
        !!subclasses.detect do |subclass|
          subclass.build?
        end
      end

      def eager_load_shared_resources!
        ActiveSupport::Dependencies.autoload_paths += ["#{Jets.root}app/shared/resources"]
        Dir.glob("#{Jets.root}app/shared/resources/*.rb").select do |path|
          next if !File.file?(path) or path =~ %r{/javascript/} or path =~ %r{/views/}
           class_name = path
                        .sub(/\.rb$/,'') # remove .rb
                        .sub(/^\.\//,'') # remove ./
                        .sub(%r{app/shared/resources/},'') # remove app/shared/resources/
                        .classify
          class_name.constantize # use constantize instead of require so dont have to worry about order.
        end
      end

      def lookup(logical_id)
        looker.output(logical_id)
      end

      def looker
        Jets::Stack::Output::Lookup.new
      end
      memoize :looker

      def output_keys
        new.outputs.map(&:template).map {|o| o.keys.first}
      end
    end
  end
end
