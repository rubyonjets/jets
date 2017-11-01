# Build::Deducers figure out required values to process the node shim
class Jets::Build
  class Deducer
    autoload :BaseDeducer, "jets/build/deducer/base_deducer"
    autoload :ControllerDeducer, "jets/build/deducer/controller_deducer"
    autoload :JobDeducer, "jets/build/deducer/job_deducer"
  end
end
