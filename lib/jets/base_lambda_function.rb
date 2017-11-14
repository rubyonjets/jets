  require 'json'

# BaseLambdaFunction is the superclass of:
#   Jets::Controller::Base
#   Jets::Job::Base
module Jets
  class BaseLambdaFunction
    attr_reader :event, :context
    def initialize(event, context, meth)
      @event = event # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
      @meth = meth
      # store meth because it is useful to for identifying the which template
      # to use later.
    end

    def lambda_functions
      self.class.lambda_functions
    end

    # The public methods defined in the project app class ulimately become
    # lambda functions.
    #
    # Example return value:
    #   [":index", :new, :create, :show]
    def self.lambda_functions
      # public_instance_methods(false) - to not include inherited methods
      functions = public_instance_methods(false) - Object.public_instance_methods
      functions.sort
    end
  end
end
