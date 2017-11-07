  require 'json'

# This is the model that Jets::BaseController and Jets::BaseJob inherits from
module Jets
  class BaseLambdaFunction
    attr_reader :event, :context
    def initialize(event, context)
      @event = event # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
    end

    # The public methods defined in the project app class ulimately become
    # lambda functions.
    #
    # Example return value:
    #   [":index", :new, :create, :show]
    def lambda_functions
      # public_instance_methods(false) - to not include inherited methods
      functions = self.class.public_instance_methods(false) - Object.public_instance_methods
      functions.sort
    end

    def self.lambda_functions
      new(nil, nil).lambda_functions
    end
  end
end
