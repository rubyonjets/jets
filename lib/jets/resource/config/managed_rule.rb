# ManagedRule is just different enough to be a separate class vs being part of the
# ConfigRule class itself.
module Jets::Resource::Config
  class ManagedRule < ConfigRule
    def initialize(app_class, meth, props)
      @app_class = app_class.to_s
      @meth = meth
      @props = props # associated_properties from dsl.rb
    end

    def definition_properties
      {
        config_rule_name: config_rule_name,
        source: {
          owner: "AWS",
          source_identifier: @meth.upcase,
        },
      }.merge(@props)
    end

    def config_rule_name
      name_without_rule = @app_class.underscore.gsub(/_rule$/,'')
      "#{name_without_rule}_#{@meth}".dasherize
    end
  end
end