require 'recursive-open-struct'

describe Jets::Resource::ApiGateway::RestApi::Routes::Change::Page do
  let(:page) do
    Jets::Resource::ApiGateway::RestApi::Routes::Change::Page.new
  end
  let(:path) { 'spec/fixtures/resource_pages/demo-test-api-resources-1.yml' }
  let(:page_number) { 1 }

  context "moved?" do
    it "same routes" do
      new_pages = {
        HiApiResource:  1,
        Hi1ApiResource: 1,
        Hi2ApiResource: 2,
        Hi3ApiResource: 2,
        Hi4ApiResource: 3,
      }
      deployed_pages = {
        HiApiResource:  1,
        Hi1ApiResource: 1,
        Hi2ApiResource: 2,
        Hi3ApiResource: 2,
        Hi4ApiResource: 3,
      }
      moved = page.moved?(new_pages, deployed_pages)
      expect(moved).to be false
    end

    it "new routes" do
      new_pages = {
        HiApiResource:  1,
        Hi1ApiResource: 1,
        Hi2ApiResource: 2,
        Hi3ApiResource: 2,
        Hi4ApiResource: 3,
      }
      deployed_pages = {
        HiApiResource:  1,
      }
      moved = page.moved?(new_pages, deployed_pages)
      expect(moved).to be false
    end

    it "route moved page" do
      new_pages = {
        HiApiResource:  1,
        Hi1ApiResource: 1,
        Hi2ApiResource: 2, # <= moved
        Hi3ApiResource: 2,
        Hi4ApiResource: 3,
      }
      deployed_pages = {
        HiApiResource:  1,
        Hi1ApiResource: 1,
        Hi2ApiResource: 1, # <= moved
        Hi3ApiResource: 2,
        Hi4ApiResource: 3,
      }
      moved = page.moved?(new_pages, deployed_pages)
      expect(moved).to be true
    end
  end

  context "local_logical_ids_map" do
    it "load map from generated templates" do
      logical_ids = page.local_logical_ids_map("spec/fixtures/resource_pages/demo-test-api-resources-*.yml")
      expected = {
        "HiApiResource"=>"1",
        "Hi1ApiResource"=>"1",
        "Hi2ApiResource"=>"2",
        "Hi3ApiResource"=>"2",
        "Hi4ApiResource"=>"3",
      }
      expect(logical_ids).to eq(expected)
    end
  end

  context "remote_logical_ids_map" do
    it "load map from deployed cloudformation stack" do
      cfn = double(:cfn).as_null_object
      child_stacks = OpenStruct.new(
        stack_resources: [
          OpenStruct.new(physical_resource_id: "demo-test-ApiResources1-")
        ]
      )
      api_resources = OpenStruct.new(
        stack_resources: [
          OpenStruct.new(logical_resource_id: "HiApiResource"),
          OpenStruct.new(logical_resource_id: "Hi1ApiResource"),
        ]
      )

      allow(cfn).to receive(:describe_stack_resources).and_return(child_stacks)
      allow(cfn).to receive(:describe_stack_resources).with(stack_name: "demo-test-ApiResources1-").and_return(api_resources)
      allow(page).to receive(:cfn).and_return(cfn)

      logical_ids = page.remote_logical_ids_map
      expected = {"HiApiResource"=>"1", "Hi1ApiResource"=>"1"}
      expect(logical_ids).to eq(expected)
    end
  end
end
