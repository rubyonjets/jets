class Jets::Build
  class Deducer
    autoload :BaseDeducer, "jets/build/deducer/base_deducer"
    autoload :ControllerDeducer, "jets/build/deducer/controller_deducer"
    autoload :JobDeducer, "jets/build/deducer/job_deducer"
  end
end
