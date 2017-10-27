require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::AppInfo do
  let(:app) do
    Jets::Cfn::Builder::AppInfo.new("/tmp/jets_build/templates/proj-dev-posts-controller.yml")
  end

  describe "AppInfo" do
    it "contains info for app stack resource" do
      expect(app.path).to eq "/tmp/jets_build/templates/proj-dev-posts-controller.yml"
      expect(app.logical_id).to eq "PostsController"
      expect(app.template_url).to eq "s3://[region].s3.amazonaws.com/[bucket]/cfn-templates/dev/proj-dev-posts-controller.yml"
      expect(app.parameters).to eq(S3Bucket: "[bucket]", IamRole: "LambdaIamRole")
    end
  end
end
