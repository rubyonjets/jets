class Jets::Resource
  class Associated
    attr_reader :definition
    def initialize(*definition)
      @definition = definition.flatten
    end
  end
end