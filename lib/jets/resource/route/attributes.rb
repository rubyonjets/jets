class Jets::Resource::Route
  # Very close to Jets::Resource::Attributes but different initializer.
  # Does not use task.
  class Attributes < Jets::Resource::Attributes
    def cors(route)
      # puts "self #{self}"
      Cors.new(route)
      # Cors.new(@task, self)
    end
    memoize :cors
  end
end
