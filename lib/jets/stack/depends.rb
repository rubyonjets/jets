class Jets::Stack
  class Depends
    autoload :Item, "jets/stack/depends/item"

    def initialize(items)
      @items = items
    end

    def params
      result = {}
      @items.each do |item|
        logical_id = item.stack.to_s.camelize # logical_id
        dependency_outputs(logical_id).each do |output|
          dependency_class = logical_id.to_s.classify
          output_key = item.options[:class_prefix] ?
            "#{dependency_class}#{output}" : # already camelized
            output

          output_value = "!GetAtt #{dependency_class}.Outputs.#{output}"
          result[output_key] = output_value
        end
      end
      result
    end

    def stack_list
      @items.map do |item|
        item.stack.to_s.camelize # logical_id # logical_id
      end
    end

    def dependency_outputs(logical_id)
      logical_id.to_s.classify.constantize.output_keys
    end
  end
end