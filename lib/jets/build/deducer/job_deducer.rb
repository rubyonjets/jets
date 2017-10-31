class Jets::Build::Deducer
  class JobDeducer < BaseDeducer
    # interface method
    def process_type
      "job"
    end

    def functions
      [:perform]
    end
  end
end
