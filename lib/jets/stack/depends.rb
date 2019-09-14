class Jets::Stack
  class Depends
    def initialize(items)
      @items = items # Jets::Stack::Depends::Item - has stack and options properties
    end

    def params
      result = {}
      @items.each do |item|
        class_name = item.class_name
        dependency_outputs(class_name).each do |output|
          dependency_class = class_name.to_s.camelize
          output_key = item.options[:class_prefix] ?
            "#{dependency_class}#{output}" : # already camelized
            output

          output_value = "!GetAtt #{dependency_class}.Outputs.#{output}"
          result[output_key] = output_value
        end
      end
      result
    end

    # Returns CloudFormation template logical ids
    def stack_list
      @items.map(&:logical_id)
    end

  private
    def dependency_outputs(class_name)
      class_name.to_s.camelize.constantize.output_keys
    end
  end
end
