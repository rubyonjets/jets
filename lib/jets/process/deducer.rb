class Jets::Process
  class Deducer
    autoload :BaseDeducer, "jets/process/deducer/base_deducer"
    autoload :ControllerDeducer, "jets/process/deducer/controller_deducer"
    autoload :FunctionDeducer, "jets/process/deducer/function_deducer"
    autoload :JobDeducer, "jets/process/deducer/job_deducer"

    def initialize(handler)
      @handler = handler
    end

    # Figures out the right deducer class to delegate to:
    # IE: Jets::Process::Deducer::ControllerDeducer or
    #     Jets::Process::Deducer::JobDeducer
    def delegate_class
      md = @handler.match(%r{handlers/(.*?)/})
      class_name = md[1] # controllers
      "Jets::Process::Deducer::#{class_name.singularize.classify}Deducer".constantize
    end
  end
end
