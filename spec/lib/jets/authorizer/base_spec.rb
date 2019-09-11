class TestSimpleAuthorizer < Jets::Authorizer::Base
  authorizer(
    name: "MainProtect2",  # required
    identity_source: "method.request.header.Auth", # required
  )

  def protect
    resource = event[:methodArn] # "arn:aws:execute-api:us-west-2:123456789012:ymy8tbxw7b/*/GET/"

    result = build_policy(
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
    puts "result #{JSON.dump(result)}"
    result
  end
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
      puts "result:"
      puts JSON.pretty_generate(result)
    end

    it "build_policy simplest form" do
      resource = event["methodArn"]
      result = authorizer.send(:build_policy, "current_user", resource, { string_key: "value" }, "usage-key")
      puts "result:"
      puts JSON.pretty_generate(result)
    end
  end
end