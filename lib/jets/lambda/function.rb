module Jets::Lambda
  class Function < Functions
    # Override and change the signature so we do not have to provide info at
    # initialization. So:
    #
    #   hello_function = HelloFunction.new
    #   hello_function.lambda_handler(event, context)
    #
    # Normally controller and job functions initialize like this:
    #
    #   controller = PostController.new(event, context, "handler_handler")
    def initialize
    end

    def self.handler
      handler_task.meth
    end

    def self.handler_task
      tasks.first
    end

    # Used by main_processor.rb.  Same interface as controllers and jobs.
    def self.process(event, context, meth)
      function = new
      function.send(handler, event, context)
    end
  end
end
