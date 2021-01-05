require "jets/internal/app/functions/jets/base_path_mapping"

describe "base_path_mapping" do
  let(:mapping) do
    mapping = BasePathMapping.new(event, "fake_stage_name")
    allow(mapping).to receive(:deployment_stack).and_return(deployment_stack)
    allow(mapping).to receive(:deleting_parent?).and_return(deleting_parent)
    mapping
  end
  let(:deployment_stack) do
    parameters = {
      "RestApi" => "fake-rest-api",
      "DomainName" => "fake-domain-name",
      "BasePath" => base_path,
    }
    parameters = parameters.map { |k,v| OpenStruct.new(parameter_key: k, parameter_value: v) }
    {
      parameters: parameters,
      root_id: "fake-parent-stack",
    }
  end
  let(:event) do
    JSON.load(<<~EOL)
    {
      "RequestType": "#{request_type}",
      "ServiceToken": "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-jets-base-path-20210105230228",
      "ResponseURL": "https://cloudformation-custom-resource-response-uswest2.s3-us-west-2.amazonaws.com/arn%3Aaws%3Acloudformation%3Aus-west-2%3A112233445566%3Astack/demo-dev-ApiDeployment20210105230228-1D1N5RX92CRC5/32027ab0-4faa-11eb-aa8e-0a949e794ddf%7CBasePathMapping%7Cd931675a-7230-4820-aca4-dc5e054405af?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210105T230346Z&X-Amz-SignedHeaders=host&X-Amz-Expires=7200&X-Amz-Credential=AKIA54RCMT6SEP3BXUV5%2F20210105%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=56ad77cdfae5e19d259bcdddf8d53d300354067c021026de2d8f1e34d1b4ac06",
      "StackId": "fake-stack-id",
      "RequestId": "d931675a-7230-4820-aca4-dc5e054405af",
      "LogicalResourceId": "BasePathMapping",
      "ResourceType": "Custom::BasePathMapping",
      "ResourceProperties": {
        "ServiceToken": "arn:aws:lambda:us-west-2:112233445566:function:demo-dev-jets-base-path-20210105230228"
      }
    }
    EOL
  end
  let(:request_type)    { "Create" }
  let(:deleting_parent) { false }
  let(:base_path)       { nil }

  context "typical update" do
    it "update" do
      expect(mapping.apigateway).to receive(:delete_base_path_mapping)
      expect(mapping.apigateway).to receive(:create_base_path_mapping)
      mapping.update
    end

    it "delete" do
      expect(mapping.apigateway).to receive(:delete_base_path_mapping)
      expect(mapping.apigateway).not_to receive(:create_base_path_mapping)
      mapping.delete
    end
  end

  context "deleting jets app" do
    let(:request_type) { "Delete" }
    let(:deleting_parent) { true }

    it "delete" do
      expect(mapping.apigateway).to receive(:delete_base_path_mapping)
      expect(mapping.apigateway).not_to receive(:create_base_path_mapping)
      mapping.delete
    end
  end

  context "base path not set" do
    let(:base_path) { nil }

    it "update" do
      expect(mapping.apigateway).to receive(:delete_base_path_mapping)
      expect(mapping.apigateway).to receive(:create_base_path_mapping)
      mapping.update
    end
  end

  context "base path not set" do
    let(:base_path) { "fake-base_path" }

    it "update" do
      expect(mapping.apigateway).to receive(:delete_base_path_mapping)
      expect(mapping.apigateway).to receive(:create_base_path_mapping)
      mapping.update
    end
  end
end
