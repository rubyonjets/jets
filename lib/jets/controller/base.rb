require "json"
require "rack/utils" # Rack::Utils.parse_nested_query

# Controller public methods get turned into Lambda functions.
class Jets::Controller
  class Base < Jets::Lambda::Functions
    include ActiveSupport::Rescuable
    include Authorization
    include Callbacks
    include Cookies
    include ForgeryProtection
    include Jets::Router::Helpers
    include Layout
    include Params
    include Rendering

    delegate :headers, to: :request
    delegate :set_header, to: :response
    attr_reader :request, :response
    attr_accessor :session
    def initialize(event, context={}, meth)
      super
      @request = Request.new(event, context)
      @response = Response.new
    end

    # Overrides Base.process
    def self.process(event, context={}, meth)
      controller = new(event, context, meth)
      # Using send because process! is private method in Jets::RackController so
      # it doesnt create a lambda function.  It's doesnt matter what scope process!
      # is in Controller::Base because Jets lambda functions inheritance doesnt
      # include methods in Controller::Base.
      # TODO: Can process! be a protected method to avoid this?
      controller.send(:process!)
    end

    # One key difference between process! vs dispatch!
    #
    #    process! - takes the request through the middleware stack
    #    dispatch! - does not
    #
    # Most of the time, you want process! instead of dispatch!
    #
    def process!
      adapter = Jets::Controller::Rack::Adapter.new(event, context, meth)
      adapter.rack_vars(
        'jets.controller' => self,
        'lambda.context' => context,
        'lambda.event' => event,
        'lambda.meth' => meth,
      )

      # adapter.process calls
      #
      #     Jets.application.call(env)
      #
      # and that goes through the middleware stacks. The last middleware stack is Jets::Controller::Middleware::Main
      #
      #     class Jets::Controller::Middleware::Main
      #       def call!
      #         setup
      #         @controller.dispatch! # Returns triplet
      #       end
      #     end
      #
      adapter.process # Returns API Gateway hash structure
    end

    # One key difference between process! vs dispatch!
    #
    #    process! - takes the request through the middleware stack
    #    dispatch! - does not
    #
    # dispatch! is useful for megamode or mounted applications
    #
    def dispatch!
      t1 = Time.now
      log_start

      begin
        if run_before_actions(break_if: -> { @rendered })
          send(@meth)
          action_completed = true
        else
          Jets.logger.info "Filter chain halted as #{@last_callback_name} rendered or redirected"
        end

        triplet = ensure_render
        run_after_actions if action_completed
      rescue Exception => exception
        rescue_with_handler(exception) || raise
        triplet = ensure_render
      end

      took = Time.now - t1
      status = triplet[0]
      log_finish(status: status, took: took)
      triplet # status, headers, body
    end

    # Documented interface method, careful not to rename
    def log_start
      # JSON.dump makes logging look pretty in CloudWatch logs because it keeps it on 1 line
      ip = request.ip
      Jets.logger.info "Started #{@event['httpMethod']} \"#{@event['path']}\" for #{ip} at #{Time.now}"
      Jets.logger.info "Processing #{self.class.name}##{@meth}"
      Jets.logger.info "  Event: #{event_log}"
      Jets.logger.info "  Parameters: #{JSON.dump(filtered_parameters.to_h)}"
    end

    # Documented interface method, careful not to rename
    def log_finish(options={})
      status, took = options[:status], options[:took]
      Jets.logger.info "Completed Status Code #{status} in #{took}s"
    end

    def event_log
      display_event = @event.dup

      if @event['isBase64Encoded']
        display_event['body'] = '[BASE64_ENCODED]'
      else
        display_event['body'] = parameter_filter.filter_json(display_event['body'])
      end

      display_event["queryStringParameters"] = parameter_filter.filter(display_event['queryStringParameters'])
      display_event["pathParameters"] = parameter_filter.filter(display_event['pathParameters'])
      json_dump(display_event)
    end

    # Handles binary data safely
    def json_dump(data)
      JSON.dump(data)
    rescue Encoding::UndefinedConversionError
      data['body'] = '[BINARY]'
      JSON.dump(data)
    end

    def controller_paths
      paths = []
      klass = self.class
      while klass != Jets::Controller::Base
        paths << klass.controller_path
        klass = klass.superclass
      end
      paths
    end

    def controller_name
      self.class.to_s.underscore
    end

    def action_name
      @meth
    end

    class_attribute :internal_controller
    class << self
      def internal(value=nil)
        if !value.nil?
          self.internal_controller = value
        else
          self.internal_controller
        end
      end

      def helper_method(*meths)
        meths.each do |meth|
          Jets::Router::Helpers.define_helper_method(meth)
        end
      end
    end
  end
end
