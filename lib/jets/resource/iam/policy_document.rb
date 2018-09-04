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
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_sid.html
      @sid = 0 # counter
    end

    def policy_document
      definitions.map { |definition| standardize(definition) }
      Jets::Pascalize.pascalize(@policy)
    end
    memoize :policy_document # only process policy_document once

    def standardize(definition)
      @sid += 1
      case definition
      when String
        @policy[:statement] << {
          sid: "Stmt#{@sid}",
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

    # Need to underscore and then classify again for this case:
    #   Jets::PreheatJob_policy => JetsPreheatJobPolicy
    # Or else you we get this:
    #   Jets::PreheatJob_policy => JetsPreheatjobPolicy
    def classify_name(text)
      text.gsub('::','_').underscore.classify
    end
  end
end
