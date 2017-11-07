class Jets::Build::Deducer
  class JobDeducer < BaseDeducer
    # interface method
    def process_type
      "job"
    end
  end
end
