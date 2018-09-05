require "active_support/core_ext/hash"
require "active_support/core_ext/object"
require "json"
require "rack/utils" # Rack::Utils.parse_nested_query

# Controller public methods get turned into Lambda functions.
class Jets::Controller
  class Base < Jets::Lambda::Functions
    include Layout
    include Callbacks
    include Rendering
    include Params

    def self.process(event, context={}, meth)
      t1 = Time.now
      Jets.logger.info "Processing by #{self}##{meth}"

      controller = new(event, context, meth)

      Jets.logger.info "  Event: #{event.inspect}"
      Jets.logger.info "  Parameters: #{controller.params(true).to_h.inspect}"

      controller.run_before_actions
      controller.send(meth)
      resp = controller.ensure_render
      controller.run_after_actions

      took = Time.now - t1
      Jets.logger.info "Completed Status Code #{resp["statusCode"]} in #{took}s"

      resp
    end

    delegate :headers, to: :request
    attr_reader :request
    def initialize(event, context={}, meth)
      super
      @request = Request.new(event)
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
