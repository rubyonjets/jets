module Jets::Resource::Iam
  class PolicyDocument
    extend Memoist

    attr_reader :definitions
    def initialize(*definitions)
      @definitions = definitions.flatten
      # empty starting policy that will be altered
      @policy = {
        version: "2012-10-17",
        statement: []
      }
    end

    def policy_document
      definitions.map { |definition| standardize(definition) }
      Jets::Camelizer.transform(@policy)
    end
    memoize :policy_document # only process policy_document once

    def standardize(definition)
      case definition
      when String
        # Expands simple string from: logs => logs:*
        definition = "#{definition}:*" unless definition.include?(':')
        @policy[:statement] << {
          action: [definition],
          effect: "Allow",
          resource: "*",
        }
      when Hash
        definition = definition.stringify_keys
        if definition.key?("Version") # special case where we replace the policy entirely
          @policy = definition
        else
          @policy[:statement] << definition
        end
      end
    end
  end
end
