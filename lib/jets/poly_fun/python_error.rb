class Jets::PolyFun
  class PythonError < StandardError
    def initialize(message, backtrace)
      super(message)
      set_backtrace(backtrace)
    end
  end
end