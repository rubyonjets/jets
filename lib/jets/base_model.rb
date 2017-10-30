require 'json'

# This is the model that Jets::BaseController and Jets::BaseJob inherits from
module Jets
  class BaseModel
    attr_reader :event, :context
    def initialize(event, context)
      @event = event # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
    end

    # The public methods defined in the user's custom class will become
    # lambda functions.
    # Returns Example:
    #   ["FakeController#handler1", "FakeController#handler2"]
    def lambda_functions
      # public_instance_methods(false) - to not include inherited methods
      self.class.public_instance_methods(false) - Object.public_instance_methods
    end

    def self.lambda_functions
      new(nil, nil).lambda_functions
    end
  end
end