class Jets::Build::Deducer
  class ControllerDeducer < BaseDeducer
    # interface method
    def process_type
      "controller"
    end
  end
end
