require 'json'

module Jets
  # The interface perform method will have a corresponding Lambda function.
  class BaseJob < BaseLambdaFunction
    # perform is the interface method that should be implemented by app
    # def perform; end
  end
end
