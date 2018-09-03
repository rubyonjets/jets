class Jets::Resource::Route
  class Attributes < Jets::Resource::Attributes
    def cors(route)
      Cors.new(route)
    end
    memoize :cors
  end
end
