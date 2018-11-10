require "active_support/core_ext/hash"
require "active_support/core_ext/object"
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
      t1 = Time.now
      Jets.logger.info "Processing by #{self.class.name}##{@meth}"
      Jets.logger.info "  Event: #{@event.inspect}"
      Jets.logger.info "  Parameters: #{params(raw: true).to_h.inspect}"

      run_before_actions
      send(@meth)
      triplet = ensure_render
      run_after_actions

      took = Time.now - t1
      status = triplet[0]
      Jets.logger.info "Completed Status Code #{status} in #{took}s"

      triplet # status, headers, body
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
  end
end
