# Does not do full expansion, mainly a container that holds the definition and
# standardizes it without camelizing it.
class Jets::Resource
  class Associated
    extend Memoist

    attr_reader :definition
    def initialize(*definition)
      @definition = definition.flatten
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