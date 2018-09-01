# Overrides
#   replace_core_values
module Jets::Resource::Replacer
  class ConfigRule < Base
    def core_replacements
      {
        config_rule_name: config_rule_name
      }
    end

    # conventional config rule name
    def config_rule_name
      name_without_rule = @class_name.underscore.gsub(/_rule$/,'')
      "#{name_without_rule}_#{@task.meth}".dasherize
    end
  end
end
