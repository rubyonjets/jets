require "spec_helper"

describe Jets::Cfn::Mappers::ChildMapper do
  let(:app) do
    Jets::Cfn::Mappers::ChildMapper.new("/tmp/jets_build/templates/#{Jets::Config.project_namespace}-posts-controller.yml", "s3-bucket")
  end

  describe "ChildMapper" do
    it "contains info for app stack resource" do
      expect(app.path).to eq "/tmp/jets_build/templates/#{Jets::Config.project_namespace}-posts-controller.yml"
      expect(app.logical_id).to eq "PostsController"
      expect(app.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets::Config.project_namespace}-posts-controller.yml"
      expect(app.parameters).to be_a(Hash)
    end
  end
end
