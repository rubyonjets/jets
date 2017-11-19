require 'json'

# Job public methods get turned into Lambda functions.
class Jets::Job
  class Base < Jets::Lambda::Function
    include Dsl

    class << self
      def process(context, event, meth)
        job = new(context, event, meth)
        job.send(meth)
      end

      def perform_now(meth, event, context=nil)
        new(event, context, meth).send(meth)
      end

      def perform_later(meth, event, context=nil)
        function_name = "#{self.to_s.underscore}-#{meth}"
        call = Jets::Call.new(function_name, JSON.dump(event))
        call.run
      end
    end
  end
end
