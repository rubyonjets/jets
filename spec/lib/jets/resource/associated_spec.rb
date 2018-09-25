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
    it "standardized format" do
      expect(associated.logical_id).to eq :"{namespace}EventsRule1"
      attributes = associated.attributes
      # pp associated  # uncomment to see and debug
      # pp attributes # uncomment to see and debug
      expect(attributes[:type]).to eq "AWS::Events::Rule"
    end
  end
end
