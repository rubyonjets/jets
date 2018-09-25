describe Jets::Resource::Associated do
  let(:associated) { Jets::Resource::Associated.new(definition) }
  let(:definition) do
    {
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
  end

  context "long form" do
    it "cloudformation format" do
      # pp associated  # uncomment to see and debug
      # pp associated.logical_id # uncomment to see and debug
      # pp associated.attributes # uncomment to see and debug
      # pp associated.properties # uncomment to see and debug

      # expect(permission.logical_id).to eq "HardJobDigPermission1"
      # properties = permission.properties
      # # pp properties # uncomment to debug
      # expect(properties["Principal"]).to eq "events.amazonaws.com"
      # expect(properties["SourceArn"]).to eq "!GetAtt HardJobDigEventsRule1.Arn"
    end
  end
end

