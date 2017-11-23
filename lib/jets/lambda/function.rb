module Jets::Lambda
  class Function < Functions
    # Override and change the signature so we do not have to provide info at
    # instance initialization like in the normal Functions. So:
    #
    #   hello_function = HelloFunction.new
    #   hello_function.lambda_handler(event, context)
    #
    # instead of:
    #
    #   hello_function = HelloFunction.new(event, context, "handler_handler")
    #   hello_function.lambda_handler(event, context)
    def initialize
    end

    def self.handler_task
      tasks.first
    end

    def self.handler
      handler_task.meth
    end

    def self.process(event, context, meth)
      function = new
      function.send(handler, event, context)
    end
  end
end
