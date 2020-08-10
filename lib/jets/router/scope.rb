module Jets
  class Router
    class Scope
      include Util

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

      def full_module
        items = walk_parents do |current, i, result|
          mod = current.options[:module]
          next unless mod
          result.unshift(mod)
        end

        items.empty? ? nil : items.join('/')
      end

      def full_prefix
        items = walk_parents do |current, i, result|
          prefix = current.options[:prefix]
          next unless prefix

          case current.from
          when :resources
            path_param = if current.options[:param]
              ":#{current.options[:param]}"
            else
              resource_name = prefix.to_s.split('/').last
              resource_name = ":#{resource_name.singularize}_id"
            end
            result.unshift(path_param)
            result.unshift(prefix)
          else # resource, namespace or general scope
            result.unshift(prefix)
          end
        end

        items.empty? ? nil : items.join('/')
      end

      def full_as
        items = []
        current = self
        while current
          items.unshift(current.options[:as]) # <= option_name
          current = current.parent
        end

        items.compact!
        return if items.empty?

        items = singularize_leading(items)
        items.join('_')
      end

      def walk_parents
        current, i, result = self, 0, []
        while current
          yield(current, i, result)
          current = current.parent
          i += 1
        end
        result
      end

      # singularize all except last item
      def singularize_leading(items)
        result = []
        items.each_with_index do |item, index|
          item = item.to_s
          r = index == items.size - 1 ? item : item.singularize
          result << r
        end
        result
      end

      def from
        @options[:from]
      end
    end
  end
end
