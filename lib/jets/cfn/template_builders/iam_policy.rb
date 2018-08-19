class Jets::Cfn::TemplateBuilders
  class IamPolicy
    extend Memoist

    def initialize(iam_policies)
      @iam_policies = iam_policies
      # empty base policy that we add to
      @base_policy = {
        "Version" => "2012-10-17",
        "Statement" => []
      }
      @sid = 0 # counter
    end

    def resource
      @iam_policies.map { |policy| standardize(policy) }
      @base_policy
    end
    memoize :resource # only process resource once

    def standardize(policy)
      @sid += 1
      case policy
      when String
        @base_policy["Statement"] << {
          "Sid"=>"Stmt#{@sid}",
          "Action"=>[policy],
          "Effect"=>"Allow", "Resource"=>"*",
        }
      end
    end
  end
end
