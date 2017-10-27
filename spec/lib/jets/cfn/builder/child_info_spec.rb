require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::ChildInfo do
  let(:child) do
    Jets::Cfn::Builder::ChildInfo.new("/tmp/jets_build/templates/proj-dev-posts-controller.yml")
  end

  describe "ChildInfo" do
    it "contains info for child stack resource" do
      expect(child.path).to eq "/tmp/jets_build/templates/proj-dev-posts-controller.yml"
      expect(child.logical_id).to eq "PostsController"
      expect(child.template_url).to eq "s3://[region].s3.amazonaws.com/[bucket]/cfn-templates/dev/proj-dev-posts-controller.yml"
      expect(child.parameters).to eq(S3Bucket: "[bucket]", IamRole: "LambdaIamRole")
    end
  end
end
