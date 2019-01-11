module Jets
  class Router
    class Scope
      attr_reader :options, :parent, :level
      def initialize(options = {}, parent = nil, level = 1)
        @options = options
        @parent = parent
        @level = level
      end

      def root?
        @parent.nil?
      end

      def new(options={})
        self.class.new(options, self, level + 1)
      end

      def full_namespace
        ns = []
        current = self
        while current
          ns.unshift(current.options[:namespace])
          current = current.parent
        end
        ns.empty? ? nil : ns.join('/')
      end
    end
  end
end
