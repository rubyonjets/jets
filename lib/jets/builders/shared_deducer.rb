# Deducer.new(path)
#
#   @deducer.functions.each do |function_name|
#     @deducer.handler_for(function_name)
#   end
#
# Implements:
#
#   functions
#   handler_for(function_name)
#   js_path
#
class Jets::Builders
  class SharedDeducer < Deducer
    def initialize(fun)
      @fun = fun
    end

    def functions
      [@fun.meth] # function_names
    end

    # dont need function_name arg but keeping the same interface as parent class
    def handler_for(function_name)
      @fun.handler_dest
    end

    def js_path
      @fun.handler_dest
    end
  end
end
