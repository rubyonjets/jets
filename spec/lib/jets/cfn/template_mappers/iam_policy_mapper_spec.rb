describe Jets::Cfn::TemplateMappers::IamPolicyMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::IamPolicyMapper.new(task)
  end
  let(:task) do
    PostsController.all_tasks[:new]
  end

  describe "IamPolicyMapper" do
    it "contains info for iam policy resource" do
      expect(map.logical_id).to eq "PostsControllerNewIamRole"
      expect(map.role_name).to eq "posts-controller-new-iam-role"
      iam_policy = YAML.dump(map.properties)
      # puts iam_policy # uncomment to debug
      expected_iam_policy = <<~EOL
        ---
        AssumeRolePolicyDocument:
          Version: '2012-10-17'
          Statement:
          - Effect: Allow
            Principal:
              Service:
              - lambda.amazonaws.com
            Action:
            - sts:AssumeRole
        Path: "/"
        Policies:
        - PolicyName: PostsControllerNewPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
            - Sid: Stmt1
              Action:
              - ec2:*
              Effect: Allow
              Resource: "*"
        RoleName: posts-controller-new-iam-role
      EOL
      expect(iam_policy).to eq expected_iam_policy
    end
  end
end
