class TestSimpleAuthorizer < Jets::Authorizer::Base
end

describe Jets::Authorizer::Base do
  let(:authorizer) { TestSimpleAuthorizer.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "protect" }

  context "token authorizer type" do
    let(:event) do
      json_file("spec/fixtures/authorizers/token.json")
    end
    it "build_policy full" do
      resource = event["methodArn"]
      result = authorizer.send(:build_policy,
        principal_id: "current_user",
        policy_document: {
          version: "2012-10-17",
          statement: [
            action: "execute-api:Invoke",
            effect: "Allow",
            resource: resource,
          ],
        },
        context: {
          string_key: "value",
          number_key: "1",
          boolean_key: "true"
        },
        usage_identifier_key: "whatever",
      )
      # puts "result:"
      # puts JSON.pretty_generate(result)
      expect(result.keys.sort).to eq(["context", "policyDocument", "principalId", "usageIdentifierKey"])
    end

    it "build_policy simplest form" do
      resource = event["methodArn"]
      result = authorizer.send(:build_policy, resource, "current_user", { string_key: "value" }, "usage-key")
      # puts "result:"
      # puts JSON.pretty_generate(result)
      expect(result.keys.sort).to eq(["context", "policyDocument", "principalId", "usageIdentifierKey"])
      expect(result["context"]).to eq({ string_key: "value" })  # left alone
    end
  end
end