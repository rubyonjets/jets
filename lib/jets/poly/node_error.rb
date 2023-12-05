class Jets::Poly
  class NodeError < StandardError
    def initialize(message, backtrace)
      super(message)
      set_backtrace(backtrace)
    end
  end
end