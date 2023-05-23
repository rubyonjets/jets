module Jets::Cfn
  class Resource < Base
    attr_reader :definition
    def initialize(definition, replacements)
      @definition, @replacements = definition, replacements
    end
  end
end
