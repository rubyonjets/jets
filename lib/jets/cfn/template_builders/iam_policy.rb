class Jets::Cfn::TemplateBuilders
  class IamPolicy
    extend Memoist

    def initialize(iam_policies)
      @iam_policies = iam_policies
      # empty starting policy that will be changed
      @policy = {
        "Version" => "2012-10-17",
        "Statement" => []
      }
      @sid = 0 # counter
    end

    def resource
      @iam_policies.map { |policy| standardize(policy) }
      # Thanks: https://www.mnishiguchi.com/2017/11/29/rails-hash-camelize-and-underscore-keys/
      @policy.deep_transform_keys! { |key| key.to_s.camelize }
    end
    memoize :resource # only process resource once

    def standardize(policy)
      @sid += 1
      case policy
      when String
        @policy["Statement"] << {
          "Sid"=>"Stmt#{@sid}",
          "Action"=>[policy],
          "Effect"=>"Allow", "Resource"=>"*",
        }
      when Hash
        policy = policy.stringify_keys
        if policy.key?("Version") # special case where we replace the policy entirely
          @policy = policy
        else
          @policy["Statement"] << policy
        end
      end
    end
  end
end
