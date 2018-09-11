# ManagedRule is just different enough to be a separate class vs being part of the
# ConfigRule class itself.
module Jets::Resource::Config
  class ManagedRule < ConfigRule
    def definition_properties
      {
        config_rule_name: config_rule_name,
        source: {
          owner: "AWS",
          source_identifier: @meth.upcase,
        },
      }.deep_merge(@props)
    end
  end
end