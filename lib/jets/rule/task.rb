class Jets::Rule::Task < Jets::Lambda::Task
  def config_rule_name
    @properties[:config_rule_name] || conventional_config_rule_name
  end

  def conventional_config_rule_name
    name = @class_name.underscore + "_" + @meth
    name.dasherize
  end
end
