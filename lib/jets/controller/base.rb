require "json"
require "rack/utils" # Rack::Utils.parse_nested_query

# Controller public methods get turned into Lambda functions.
class Jets::Controller
  class Base < Jets::Lambda::Functions
    include Callbacks
    include Cookies
    include Layout
    include Params
    include Rendering
    include ActiveSupport::Rescuable

    delegate :headers, to: :request
    delegate :set_header, to: :response
    attr_reader :request, :response
    attr_accessor :session
    def initialize(event, context={}, meth)
      super
      @request = Request.new(event, context)
      @response = Response.new
    end

    def process!
      adapter = Jets::Controller::Rack::Adapter.new(event, context, meth)
      adapter.rack_vars(
        'jets.controller' => self,
        'lambda.context' => context,
        'lambda.event' => event,
        'lambda.meth' => meth,
      )
      # adapter.process ultimately calls app controller action at the very last
      # middleware stack.
      adapter.process # Returns API Gateway hash structure
    end

    def dispatch!
      Jets::Autoloaders.main.reload if Jets.env.development?

      t1 = Time.now
      log_info_start

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
      Jets.logger.info "Completed Status Code #{status} in #{took}s"
      triplet # status, headers, body
    end

    def log_info_start
      display_event = @event.dup
      display_event['body'] = '[BASE64_ENCODED]' if @event['isBase64Encoded']
      # JSON.dump makes logging look pretty in CloudWatch logs because it keeps it on 1 line
      ip = request.ip
      Jets.logger.info "Started #{@event['httpMethod']} \"#{@event['path']}\" for #{ip} at #{Time.now}"
      Jets.logger.info "Processing #{self.class.name}##{@meth}"
      Jets.logger.info "  Event: #{json_dump(display_event)}"
      Jets.logger.info "  Parameters: #{JSON.dump(params(raw: true).to_h)}"
    end

    # Handles binary data safely
    def json_dump(data)
      JSON.dump(data)
    rescue Encoding::UndefinedConversionError
      data['body'] = '[BINARY]'
      JSON.dump(data)
    end

    def self.process(event, context={}, meth)
      controller = new(event, context, meth)
      # Using send because process! is private method in Jets::RackController so
      # it doesnt create a lambda function.  It's doesnt matter what scope process!
      # is in Controller::Base because Jets lambda functions inheritance doesnt
      # include methods in Controller::Base.
      controller.send(:process!)
    end

    class_attribute :internal_controller
    def self.internal(value=nil)
      if !value.nil?
        self.internal_controller = value
      else
        self.internal_controller
      end
    end

    class_attribute :auth_type
    def self.authorization_type(value=nil)
      if !value.nil?
        self.auth_type = value
      else
        self.auth_type
      end
    end
  end
end
