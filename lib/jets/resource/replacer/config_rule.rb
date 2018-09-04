# Overrides
#   replace_core_values
class Jets::Resource::Replacer
  class ConfigRule < Base
    def core_replacements
      {
        config_rule_name: config_rule_name
      }
    end

    # Conventional config rule name
    # Similar logic in Rule::Dsl.managed_rule
    def config_rule_name
      name_without_rule = @app_class.underscore.gsub(/_rule$/,'')
      "#{name_without_rule}_#{@task.meth}".dasherize
    end
  end
end
