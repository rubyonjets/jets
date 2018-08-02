require 'json'

# Jets::Lambda::Functions represents a collection of Lambda functions.
#
# Jets::Lambda::Functions is the superclass of:
#   Jets::Controller::Base
#   Jets::Job::Base
module Jets::Lambda
  class Functions
    attr_reader :event, :context, :meth
    def initialize(event, context, meth)
      @event = event # Hash, JSON.parse(event) ran BaseProcessor
      @context = context # Hash. JSON.parse(context) ran in BaseProcessor
      @meth = meth
      # store meth because it is useful to for identifying the which template
      # to use later.
    end

    include Dsl # At the end so methods like event, context and method
      # do not trigger method_added
  end
end
