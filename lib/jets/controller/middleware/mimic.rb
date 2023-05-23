require 'kramdown'

# Handles mimicing of API Gateway to Lambda function call locally
# Logic in the opposite direction: Jets::Controller::Handler::Apigw#rack_vars
module Jets::Controller::Middleware
  class Mimic
    extend Memoist

    def initialize(app)
      @app = app
    end

    def call(env)
      matcher = Jets::Router::Matcher.new
      route = matcher.find_by_env(env) # simpler version does not check constraints
      return not_found(env) unless route

      # Make instance available so we dont not have to pass it around.
      # Also important to assign to instance variables so values are memoized in variables
      # So the mimic logic work because @env.merge! does not happened
      # until end. We do not want apigw.controller to create a new controller instance
      # with a different object_id
      apigw = Apigw.new(route, env) # takes rack env and converts to API Gateway event structure
      @controller = apigw.controller
      @meth = apigw.meth
      @event = apigw.event
      @context = apigw.context

      route = matcher.find_by_request(@controller.request) # need request object to check constraints
      return not_found(env) unless route

      if route.to == 'jets/rack#process' # megamode
        # Bypass the Jets middlewares since it could interfere with the Rack
        # application's middleware stack.
        #
        # Jets sends back a transfer-encoding=chunked. Curling Jets directly works,
        # but passing the Jets response back through this middleware results in errors.
        # Disable chunking responses by deleting the transfer-encoding response header.
        # Would like to understand why this happens this better, if someone can explain please let me know.
        status, headers, body = @controller.dispatch! # jets/rack_controller
        headers.delete "transfer-encoding"
        [status, headers, body]
      elsif route.to == 'jets/mount#call' # mount route
        status, headers, body = @controller.dispatch! # jets/mount_controller
        [status, headers, body]
      elsif polymorphic_function?
        run_polymophic_function
      else # Normal Jets request
        unless on_aws?(env)
          # Only set these variables when running locally and not on AWS.
          # On AWS, these are set by the Jets::Controller::Handler::Apigw#rack_vars
          env.merge!(
            'jets.controller' => @controller, # mimic controller instance
            'jets.context'    => @context,    # mimic context
            'jets.event'      => @event,      # mimic event
            'jets.meth'       => @meth,
          )
        end
        @app.call(env) # goes to all middleware all the way to Jets::Controller::Middleware::Main
      end
    end

    # Never hit when calling polymorphic function on AWS Lambda. Can only get called with the local server.
    def polymorphic_function?
      return false if ENV['_HANDLER'] # slight speed improvement on Lambda
      polymorphic_function.definition.lang != :ruby
    end

    def polymorphic_function
      # Abusing Poly to run polymorphic code, should call LambdaExecutor directly
      # after reworking LambdaExecutor so it has a better interface.
      Jets::Poly.new(@controller.class, @meth)
    end
    memoize :polymorphic_function

    def run_polymophic_function
      resp = polymorphic_function.run(@event, @meth) # polymorphic code
      status = resp['statusCode']
      headers = resp['headers']
      body = StringIO.new(resp['body'])
      [status, headers, body] # triplet
    end

    def on_aws?(env)
      return true if ENV['ON_AWS']
      return false if Jets.env.test? # usually with test we're passing in full API Gateway fixtures with the HTTP_X_AMZN_TRACE_ID
      return false if ENV['JETS_ELB'] # If we're using an ELB and Jets is inside a container running jets server, we don't want to pretend we're on AWS.
      on_cloud9 = !!(env['HTTP_HOST'] =~ /cloud9\..*\.amazonaws\.com/)
      !!env['HTTP_X_AMZN_TRACE_ID'] && !on_cloud9
    end

    def routes_error_message(env)
      message = "<h2>404 Error: Route #{env['PATH_INFO'].sub('/','')} not found</h2>"
      if Jets.env != "production"
        message << "<p>Here are the routes defined in your application:</p>"
        message << "#{routes_table}"
      end
      message
    end

    def not_found(env)
      raise Jets::Controller::RoutingError, "No route matches #{env['PATH_INFO'].inspect}"
    end
  end
end
