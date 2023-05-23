module Jets::Cfn::Resource::Iam
  class PolicyDocument
    extend Memoist
    include Jets::Util::Camelize

    attr_reader :definitions
    def initialize(*definitions)
      @definitions = definitions.flatten
      # empty starting policy that will be altered
      @policy = {
        Version: "2012-10-17",
        Statement: []
      }
    end

    def policy_document
      definitions.map { |definition| standardize(definition) }
      camelize(@policy)
    end
    memoize :policy_document # only process policy_document once

    def standardize(definition)
      case definition
      when String
        # Expands simple string from: logs => logs:*
        definition = "#{definition}:*" unless definition.include?(':')
        @policy[:Statement] << {
          Action: [definition],
          Effect: "Allow",
          Resource: "*",
        }
      when Hash
        definition = definition.stringify_keys
        if definition.key?("Version") # special case where we replace the policy entirely
          @policy = definition
        else
          @policy[:Statement] << definition
        end
      end
    end
  end
end
