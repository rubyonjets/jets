class Jets::Util
  class << self
    # Make sure that the result is a text.
    def normalize_result(result)
      JSON.dump(result)
    end
  end
end
