# ManagedRule is just different enough to be a separate class vs being part of the
# ConfigRule class itself.
module Jets::Cfn::Resource::Config
  class ManagedRule < ConfigRule
    def definition_properties
      {
        ConfigRuleName: config_rule_name,
        Source: {
          Owner: "AWS",
          SourceIdentifier: @meth.upcase,
        },
      }.deep_merge(@props)
    end
  end
end