require "spec_helper"

describe Jets::Cfn::Builder::ApiGatewayTemplate do
  let(:builder) do
    Jets::Cfn::Builder::ApiGatewayTemplate.new({})
  end

  describe "ApiGatewayTemplate" do
    it "builds a child stack with the shared api gateway resources" do
      expect(builder.template_path).to eq "/tmp/jets_build/templates/proj-dev-api-gateway.yml"


        paths = ["posts", "posts/:id", "landing/posts", "posts/:id/edit", "landing/comments"]
        pp builder.all_paths(paths)
    end
  end
end
