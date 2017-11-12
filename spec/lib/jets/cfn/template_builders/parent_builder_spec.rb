require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ParentBuilder do
  context "first run" do
    let(:builder) do
      Jets::Cfn::TemplateBuilders::ParentBuilder.new({})
    end

    describe "compose" do
      it "builds parent template with mimnimal resources" do
        builder.compose
        puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        expect(resources).to include("S3Bucket")
        expect(resources).to include("IamRole")
        expect(resources).not_to include("CommentsController")

        resource_types = resources.values.map { |i| i["Type"] }
        expect(resource_types).to include("AWS::S3::Bucket")
        expect(resource_types).to include("AWS::IAM::Role")
        expect(resource_types).not_to include("AWS::CloudFormation::Stack")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-2-parent.yml"
      end
    end
  end

  # Spec is not passing because code relies on the child templates first being
  # generated and then it will do a Dir.glob on those files to then add
  # the child resources to the parent template.
  #
  # Leave spec here until figure out a good way to generate these or
  # test this better.
  #
  # context "second run" do
  #   let(:builder) do
  #     Jets::Cfn::TemplateBuilders::ParentBuilder.new(stack_type: "full")
  #   end

  #   describe "compose" do
  #     it "builds a child stack with the scheduled events" do
  #       builder.compose
  #       puts builder.text # uncomment to see template text

  #       resources = builder.template["Resources"]
  #       expect(resources).to include("S3Bucket")
  #       expect(resources).to include("IamRole")
  #       expect(resources).to include("CommentsController")
  #       expect(resources).to include("PostsController")
  #       expect(resources).to include("EasyJob")
  #       expect(resources).to include("HardJob")

  #       resource_types = resources.values.map { |i| i["Type"] }
  #       expect(resource_types).to include("AWS::S3::Bucket")
  #       expect(resource_types).to include("AWS::IAM::Role")
  #       expect(resource_types).to include("AWS::CloudFormation::Stack") # lots of child stacks

  #       expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-2-parent.yml"
  #     end
  #   end
  # end
end
