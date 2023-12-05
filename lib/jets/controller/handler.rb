module Jets::Controller
  # Only called by AWS Lambda before it runs through the middlewares.
  module Handler
    extend ActiveSupport::Concern

    # One key difference between process! vs dispatch!
    #
    #    process! - takes the request through the middleware stack
    #    dispatch! - does not
    #
    # Generally, we want to use process! so it goes through the middleware stacks.
    #
    # The last middleware stack is Jets::Controller::Middleware::Main
    # Which comes back to dispatch! in this same Controller Base class.
    #
    #     class Jets::Controller::Middleware::Main
    #       def call!
    #         setup
    #         @controller.dispatch! # Returns triplet
    #       end
    #     end
    #
    def process!
      apigw = Jets::Controller::Handler::Apigw.new(event, context, self, @meth, @rack_env)
      apigw.process_through_middlewares # Returns API Gateway hash structure
    end

    class_methods do
      def process(event, context={}, meth)
        rack_env = Jets::Controller::RackAdapter::Env.new(event, context).convert # convert to Rack env
        controller = new(event, context, meth, rack_env)
        # Using send because process! was a private method in Jets::RackController (old) so
        # it doesnt create a lambda function.  It's doesnt matter what scope process!
        # is in Controller::Base because Jets lambda functions inheritance doesnt
        # include methods in Controller::Base.
        controller.send(:process!)
      end
    end
  end
end

