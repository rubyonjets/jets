  require 'json'

# This is the model that Jets::BaseController and Jets::BaseJob inherits from
module Jets
  class BaseLambdaFunction
    attr_reader :event, :context
    def initialize(event, context)
      @event = event # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
    end
  end
end
