describe Jets::Cfn::Builders::ParentBuilder do
  context "first run" do
    let(:builder) do
      Jets::Cfn::Builders::ParentBuilder.new
    end

    describe "compose" do
      it "builds parent template with mimnimal resources" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        expect(resources).to include("S3Bucket")
        expect(resources).to include("IamRole")
        expect(resources).not_to include("CommentsController")

        resource_types = resources.values.map { |i| i["Type"] }
        expect(resource_types).to include("AWS::S3::Bucket")
        expect(resource_types).to include("AWS::IAM::Role")
        expect(resource_types).not_to include("AWS::CloudFormation::Stack")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test.yml"
      end
    end
  end

  context "second run" do
    let(:builder) do
      Jets::Cfn::Builders::ParentBuilder.new
    end

    describe "compose" do
      it "add_shared_resources" do
      end

      it "builds a child stack with the scheduled events" do
        # builder.compose
        # puts builder.text # uncomment to see template text

        # resources = builder.template["Resources"]
        # expect(resources).to include("S3Bucket")
        # expect(resources).to include("IamRole")
        # expect(resources).to include("CommentsController")
        # expect(resources).to include("PostsController")
        # expect(resources).to include("EasyJob")
        # expect(resources).to include("HardJob")

        # resource_types = resources.values.map { |i| i["Type"] }
        # expect(resource_types).to include("AWS::S3::Bucket")
        # expect(resource_types).to include("AWS::IAM::Role")
        # expect(resource_types).to include("AWS::CloudFormation::Stack") # lots of child stacks

        # expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-parent.yml"
      end
    end
  end
end
