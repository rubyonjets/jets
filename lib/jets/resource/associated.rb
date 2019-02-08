# Does not do full expansion, mainly a container that holds the definition and
# standardizes it without camelizing it.
class Jets::Resource
  class Associated
    extend Memoist

    attr_reader :definition
    attr_accessor :multiple_resources
    def initialize(*definition)
      @definition = definition.flatten
      # Some associated resources require multiple resources for a single Lambda function. For
      # example `sqs_event` can create a `SQS::Queue` and `Lambda::EventSourceMapping`.  We set
      # a `multiple` flag so `add_logical_id_counter` can use it to avoid adding counter ids to
      # these type of resources. The `multiple` flag allows us to handle both:
      #
      #   1. Associated resources that contain multiple resources for a single Lambda function
      #   2. A single Lambda function with multiple events.  In this case, a counter is added
      #
      # Setting `multiple` to true means the counter id will not be added.
      @multiple_resources = false
    end

    def logical_id
      standardized.keys.first
    end

    def attributes
      standardized.values.first
    end

    def standardized
      standardizer = Standardizer.new(definition)
      standardizer.standarize(definition) # doesnt camelize keys yet
    end
    memoize :standardized
  end
end