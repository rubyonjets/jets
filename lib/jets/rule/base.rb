require 'json'

# Base public methods get turned into Lambda functions.
#
# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Rule
  class Base < Jets::Lambda::Functions
    include Dsl

    class << self
      def process(event, context, meth)
        job = new(event, context, meth)
        job.send(meth)
      end
    end
  end
end
