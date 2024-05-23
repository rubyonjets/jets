class Jets::CLI::Maintenance
  class Web < Base
    def initialize(options = {})
      super
      function_name = Jets::CLI::Lambda::Lookup.function("controller")
      @lambda_function = Jets::CLI::Lambda::Function.new(function_name)
    end

    def on
      if on?
        warn "Web maintenance is already on"
      else
        @lambda_function.environment_variables = {JETS_MAINTENANCE: "on"}
        warn "Web maintenance has been turned on"
      end
    end

    def off
      if on?
        @lambda_function.environment_variables = {JETS_MAINTENANCE: nil}
        warn "Web maintenance has been turned off"
      else
        warn "Web maintenance is already off"
      end
    end

    def on?
      truthy?(@lambda_function.environment_variables["JETS_MAINTENANCE"])
    end
  end
end
