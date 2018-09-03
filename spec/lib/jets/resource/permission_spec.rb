describe Jets::Resource::Permission do
  let(:permission) { Jets::Resource::Permission.new(task, resource_attributes) }
  let(:resource_attributes) do
    Jets::Resource::Attributes.new(data, task)
  end
  let(:task) do
    task = double(:task).as_null_object
    allow(task).to receive(:meth).and_return(:disable_unused_credentials)
    task
  end
  let(:data) do
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

  context "raw cloudformation definition attributes" do
    it "attributes" do
      attributes = permission.attributes # attributes
      # the class shows up as the fake double class, which is fine for the spec
      expect(attributes.logical_id).to eq "#[Double :task]DisableUnusedCredentialsPermission1"
      properties = attributes.properties
      # pp properties # uncomment to debug
      expect(properties["Principal"]).to eq "events.amazonaws.com"
      expect(properties["SourceArn"]).to eq "!GetAtt #[Double :task]DisableUnusedCredentialsEventsRule1.Arn"
    end
  end
end

