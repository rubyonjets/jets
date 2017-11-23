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

    def self.process(event, context, meth)
      controller = new(event, context, meth)
      controller.run_before_actions
      controller.send(meth)
      resp = controller.ensure_render
      controller.run_after_actions
      resp
    end

    delegate :headers, to: :request
    attr_reader :request
    def initialize(event, context, meth)
      super
      @request = Request.new(event)
    end
  end
end
