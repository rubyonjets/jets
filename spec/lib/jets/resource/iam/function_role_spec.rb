describe Jets::Resource::Iam::FunctionRole do
  let(:role) do
    Jets::Resource::Iam::FunctionRole.new(task)
  end
  let(:task) do
    PostsController.all_public_tasks[:new]
  end

  context "iam policy" do
    it "inherits from the application and class wide iam policy" do
      # pp role.policy_document # uncomment to debug
      expect(role.policy_document).to eq(
        {"Version"=>"2012-10-17",
         "Statement"=>
          [{"Action"=>["lambda:*"], "Effect"=>"Allow", "Resource"=>"*"},
           {"Action"=>["ec2:*"], "Effect"=>"Allow", "Resource"=>"*"},
           {"Action"=>["logs:*"], "Effect"=>"Allow", "Resource"=>"*"},
           {"Action"=>["logs:*"],
            "Effect"=>"Allow",
            "Resource"=>
             "arn:aws:logs:us-east-1:123456789:log-group:/aws/lambda/demo-test-*"},
           {"Action"=>["s3:Get*", "s3:List*", "s3:HeadBucket"],
            "Effect"=>"Allow",
            "Resource"=>"arn:aws:s3:::fake-test-s3-bucket*"},
           {"Action"=>
             ["cloudformation:DescribeStacks",
              "cloudformation:DescribeStackResources"],
            "Effect"=>"Allow",
            "Resource"=>
             "arn:aws:cloudformation:us-east-1:123456789:stack/demo-test*"}]}
      )
    end
  end
end