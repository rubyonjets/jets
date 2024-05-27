class Jets::Cfn::Resource
  class AssociatedOutputs
    extend Memoist

    def initialize(outputs = {}, replacements = {})
      @outputs = outputs
      @replacements = replacements
    end

    def replacer
      Replacer.new(@replacements)
    end
    memoize :replacer

    def outputs
      outputs = replacer.replace_placeholders(@outputs)
      outputs.transform_values! { |value| value.camelize }
      outputs.transform_keys! { |key| replacer.replace_value(key) }
    end
  end
end
