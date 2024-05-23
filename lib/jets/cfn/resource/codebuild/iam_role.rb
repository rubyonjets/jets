module Jets::Cfn::Resource::Codebuild
  class IamRole < Jets::Cfn::Base
    def definition
      {
        "CodebuildRole" => {
          Type: "AWS::IAM::Role",
          Properties: props
        }
      }
    end

    # Do not name this method properties as that's a computed method
    def props
      text = <<~EOL
        AssumeRolePolicyDocument:
          Statement:
          - Action:
            - sts:AssumeRole
            Effect: Allow
            Principal:
              Service:
              - codebuild.amazonaws.com
          Version: '2012-10-17'
        Path: "/"
      EOL
      props = YAML.load(text).deep_symbolize_keys
      props[:Policies] = policies
      props[:ManagedPolicyArns] = managed_policy_arns
      props
    end

    def policies
      [default_policy, custom_policy, vpc_policy].flatten.compact
    end

    def default_policy
      Jets::Cfn::Iam::Policy.new("DefaultPolicy", config.codebuild.iam.default_policy).standardize
    end

    def vpc_policy
      policy = config.codebuild.iam.default_vpc_policy
      if !policy.nil? && !policy.empty?
        Jets::Cfn::Iam::Policy.new("VpcPolicy", policy).standardize
      end
    end

    def custom_policy
      Jets::Cfn::Iam::Policy.new("CustomPolicy", config.codebuild.iam.policy).standardize
    end

    def managed_policy_arns
      [default_managed_policy, custom_managed_policy].flatten.compact
    end

    def default_managed_policy
      Jets::Cfn::Iam::ManagedPolicy.new(config.codebuild.iam.default_managed_policy).standardize
    end

    def custom_managed_policy
      Jets::Cfn::Iam::ManagedPolicy.new(config.codebuild.iam.managed_policy).standardize
    end
  end
end
