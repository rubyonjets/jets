class Jets::SharedResource
  class Base
    def initialize(shared_class)
      @shared_class = shared_class
    end

    def standardize_definition(*args)
      if args.size == 1
        args.first
      else
        logical_id = args[0]
        properties = args[1]
        {
          logical_id => {
            type: "AWS::Sns::Topic",
            properties: properties
          }
        }
      end
    end
  end
end