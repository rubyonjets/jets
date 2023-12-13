module Jets::Cfn::Iam
  # Examples:
  # config.codebuild.iam.managed_policies = [AmazonSSMReadOnlyAccess]
  class ManagedPolicy
    def initialize(policies)
      @policies = policies.compact.flatten.uniq
    end

    def standardize
      return if @policies.nil? || @policies.empty?

      @policies.map do |policy|
        if policy.include?("arn:")
          policy
        else
          "arn:aws:iam::aws:policy/#{policy}"
        end
      end
    end
  end
end
