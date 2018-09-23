class Jets::Resource
  class Definition
    attr_reader :raw
    def initialize(*raw)
      @raw = raw.flatten
    end
  end
end