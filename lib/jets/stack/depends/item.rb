# Usage examples:
#
#   Jets::Stack::Depends::Item.new(:custom)
#   Jets::Stack::Depends::Item.new(:custom, :alert)
#   Jets::Stack::Depends::Item.new(:custom, class_prefix: true)
#   Jets::Stack::Depends::Item.new(:custom, :alert, class_prefix: true)
#
# The Jets::Stack::Depends#params uses the options to determine if the class prefix should be added.
#
class Jets::Stack::Depends
  class Item
    attr_reader :stack, :options
    def initialize(stack, options={})
      @stack = stack # should be underscore format. IE: admin/posts_controller
      @options = options
    end

    def logical_id
      @stack.to_s.gsub('::','').gsub('/','_').camelize
    end

    def class_name
      @stack.to_s.camelize
    end
  end
end
