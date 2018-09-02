class Jets::Resource::Route
  class Attributes < Jets::Resource::Attributes
    def cors
      Cors.new(@task, self)
    end
    memoize :cors
  end
end
