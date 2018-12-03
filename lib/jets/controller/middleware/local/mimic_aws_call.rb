class Jets::Controller::Middleware::Local
  class MimicAwsCall
    extend Memoist

    def initialize(route, env)
      @route, @env = route, env
    end

    def vars
      {
        'jets.controller' => controller,
        'lambda.context' => context,
        'lambda.event' => event,
        'lambda.meth' => meth,
      }
    end

    # Actual controller instance
    def controller
      controller_class = @route.controller_name.constantize
      meth = @route.action_name
      controller_class.new(event, context, meth)
    end

    def meth
      @route.action_name
    end

    def event
      @env['adapter.event'] || ApiGateway.new(@route, @env).event
    end
    memoize :event

    def context
      @env['adapter.context'] || {"fake" => "context in mimic_aws_call.rb"}
    end
  end
end
