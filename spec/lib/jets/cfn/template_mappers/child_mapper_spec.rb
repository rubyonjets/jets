require "spec_helper"

describe Jets::Cfn::TemplateMappers::ChildMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ChildMapper.new("#{Jets.tmpdir}/templates/#{Jets.config.project_namespace}-posts-controller.yml", "s3-bucket")
  end

  describe "map" do
    it "contains info for app stack resource" do
      expect(map.path).to eq "#{Jets.tmpdir}/templates/#{Jets.config.project_namespace}-posts-controller.yml"
      expect(map.logical_id).to eq "PostsController"
      expect(map.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-posts-controller.yml"
      expect(map.parameters).to be_a(Hash)
    end
  end
end
