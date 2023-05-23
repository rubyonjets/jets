describe Jets::Cfn::Resource::Iam::ClassRole do
  let(:role) do
    reset_application_config_iam!
    Jets::Cfn::Resource::Iam::ClassRole.new(PostsController)
  end

  context "iam policy" do
    it "inherits from the application wide iam policy" do
      puts "role.policy_document".color(:purple)
      pp role.policy_document
      expect(role.policy_document).to eq(
        {:Version=>"2012-10-17",
          :Statement=>
           [{:Action=>["logs:*"],
             :Effect=>"Allow",
             :Resource=>"arn:aws:logs:us-east-1:123456789:log-group:/aws/lambda/demo-test-*"},
            {:Action=>["s3:Get*", "s3:List*", "s3:HeadBucket"],
             :Effect=>"Allow",
             :Resource=>"arn:aws:s3:::fake-test-s3-bucket*"},
            {:Action=>["cloudformation:DescribeStacks", "cloudformation:DescribeStackResources"],
             :Effect=>"Allow",
             :Resource=>"arn:aws:cloudformation:us-east-1:123456789:stack/demo-test*"}]}
      )
    end
  end
end