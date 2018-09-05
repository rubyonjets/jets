class Jets::Cfn::Builders
  class RuleBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_resources
      add_managed_rules
    end

    # Handle config_rules associated with aws managed rules.
    # List of AWS Config Managed Rules: https://amzn.to/2BOt9KN
    def add_managed_rules
      @app_klass.managed_rules.each do |rule|
        resource = Jets::Resource.new(rule[:definition], rule[:replacements])
        add_resource(resource)
      end
    end
  end
end
