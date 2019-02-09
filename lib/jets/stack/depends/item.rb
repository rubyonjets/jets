class Jets::Stack::Depends
  class Item
    attr_reader :stack, :options
    def initialize(stack, options={})
      @stack = stack
      @options = options
    end
  end
end
