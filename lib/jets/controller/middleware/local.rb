require 'kramdown'

# Handles mimicking of API Gateway to Lambda function call locally
module Jets::Controller::Middleware
  class Local
    extend Memoist

    def initialize(app)
      @app = app
    end

    def call(env)
      route = RouteMatcher.new(env).find_route
      unless route
        return [404, {'Content-Type' => 'text/html'}, not_found(env)]
      end

      mimic = MimicAwsCall.new(route, env)
      # Make @controller and @meth instance available so we dont not have to pass it around.
      @controller, @meth, @event = mimic.controller, mimic.meth, mimic.event

      if route.to == 'jets/rack#process' # megamode
        # Bypass the Jets middlewares since it could interfere with the Rack
        # application's middleware stack.
        #
        # Rails sends back a transfer-encoding=chunked. Curling Rails directly works,
        # but passing the Rails response back through this middleware results in errors.
        # Disable chunking responses by deleting the transfer-encoding response header.
        # Would like to understand why this happens this better, if someone can explain please let me know.
        status, headers, body = @controller.dispatch! # jets/rack_controller
        headers.delete "transfer-encoding"
        [status, headers, body]
      elsif polymorphic_function?
        # Will never hit when calling polymorphic function on AWS Lambda.
        # This can only really get called with the local server.
        run_polymophic_function
      else # Normal Jets request
        mimick_aws_lambda!(env, mimic.vars) unless on_aws?(env)
        @app.call(env)
      end
    end

    def polymorphic_function?
      polymorphic_function.task.lang != :ruby
    end

    def polymorphic_function
      # Abusing PolyFun to run polymorphic code, should call LambdaExecutor directly
      # after reworking LambdaExecutor so it has a better interface.
      Jets::PolyFun.new(@controller.class, @meth)
    end
    memoize :polymorphic_function

    def run_polymophic_function
      resp = polymorphic_function.run(@event, @meth) # polymorphic code
      status = resp['statusCode']
      headers = resp['headers']
      body = StringIO.new(resp['body'])
      [status, headers, body] # triplet
    end

    # Modifies env the in the same way real call from AWS lambda would modify env
    def mimick_aws_lambda!(env, vars)
      env.merge!(vars)
      env
    end

    def on_aws?(env)
      return false if ENV['TEST'] # usually with test we're passing in full API Gateway fixtures with the HTTP_X_AMZN_TRACE_ID
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
      message = routes_error_message(env)
      body = <<~HTML
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset="utf-8">
                <title>Route not found</title>
            </head>
            <body>
              #{message}
            </body>
        </html>
      HTML
      StringIO.new(body)
    end

    # Show pretty route table for user to help with debugging in non-production mode
    def routes_table
      routes = Jets::Router.routes

      return "Your routes table is empty." if routes.empty?

      text = "Verb | Path | Controller#action\n"
      text << "--- | --- | ---\n"
      routes.each do |route|
        text << "#{route.method} | #{route.path} | #{route.to}\n"
      end
      html = Kramdown::Document.new(text).to_html
      puts html
      html
    end
  end
end
