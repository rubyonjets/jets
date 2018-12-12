# Jets::Builders::ShimVars::Shared.new(fun)
#
#   @deducer.functions.each do |function_name|
#     @deducer.handler_for(function_name)
#   end
#
# Implements:
#
#   functions: IE [:index, :show]
#   handler_for(function_name): IE handlers/controllers/posts_controller.index
#   dest_path: IE: handlers/controllers/posts_controller.js
#
module Jets::Builders::ShimVars
  class Shared < Base
    # fun is a Jets::Stack::Function
    def initialize(fun)
      @fun = fun
    end

    # Always only one element for shared functions
    # functions: IE [:handle]
    def functions
      [@fun.meth] # function_names
    end

    # Dont need function_name arg but keeping the same interface as parent class
    # IE handlers/shared/functions/bob.handle
    def handler_for(function_name)
      @fun.handler_dest
    end

    # IE handlers/shared/functions/bob.js
    def dest_path
      @fun.handler_dest
    end
  end
end
