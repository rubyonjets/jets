class Jets::Cfn::Builder
  class Rule < Nested
    # interface method
    def compose
      add_common_parameters
      add_functions
      add_resources
      add_managed_rules
    end

    # Handle config_rules associated with aws managed rules.
    # List of AWS Config Managed Rules: https://amzn.to/2BOt9KN
    def add_managed_rules
      @app_class.managed_rules.each do |rule|
        resource = Jets::Cfn::Resource.new(rule[:definition], rule[:replacements])
        add_resource(resource)
      end
    end
  end
end
