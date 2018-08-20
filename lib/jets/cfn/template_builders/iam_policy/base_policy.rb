# Classes that inherit this Base class should implement:
#
#   initialize - should call setup in it
#   policy_name
#
module Jets::Cfn::TemplateBuilders::IamPolicy
  class BasePolicy
    extend Memoist

    attr_reader :definitions
    # Not using initialize because method signature is different
    def setup
      # empty starting policy that will be changed
      @policy = {
        "Version" => "2012-10-17",
        "Statement" => []
      }
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_sid.html
      @sid = 0 # counter
    end

    def policy_document
      definitions.map { |definition| standardize(definition) }
      # Thanks: https://www.mnishiguchi.com/2017/11/29/rails-hash-camelize-and-underscore-keys/
      @policy.deep_transform_keys! { |key| key.to_s.camelize }
    end
    memoize :policy_document # only process policy_document once

    def standardize(definition)
      @sid += 1
      case definition
      when String
        @policy["Statement"] << {
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
          @policy["Statement"] << definition
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
