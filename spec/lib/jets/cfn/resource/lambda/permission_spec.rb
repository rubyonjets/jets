describe Jets::Cfn::Resource::Lambda::Permission do
  let(:permission) { Jets::Cfn::Resource::Lambda::Permission.new(replacements, associated_resource) }
  let(:associated_resource) do
    definition = {
      "{namespace}EventsRule1": {
        type: "AWS::Events::Rule",
        properties: {
          schedule_expression: "rate(10 hours)",
          state: "ENABLED",
          targets: [{
            arn: "!GetAtt {namespace}LambdaFunction.Arn",
            id: "{namespace}RuleTarget"
          }]
        } # closes properties
      }
    }
    Jets::Cfn::Resource.new(definition, replacements)
  end
  let(:replacements) { {namespace: "HardJobDig"} }

  context "raw cloudformation definition" do
    it "permission" do
      expect(permission.logical_id).to eq "HardJobDigPermission1"
      properties = permission.properties
      expect(properties[:Principal]).to eq "events.amazonaws.com"
      expect(properties[:SourceArn]).to be nil
    end
  end
end

