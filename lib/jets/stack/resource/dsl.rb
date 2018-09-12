class Jets::Stack
  class Resource
    module Dsl
      def resources
        Resource.definitions
      end

      # TODO: use ActiveSuport concerns instead
      def self.included(base)
        base.extend DslMethods
      end

      module DslMethods
        def resource(*definition)
          Resource.new(*definition).register
        end
      end
    end
  end
end
