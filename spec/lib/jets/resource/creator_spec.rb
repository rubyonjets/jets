describe Jets::Resource::Creator do
  let(:creator) { Jets::Resource::Creator.new(definition, task) }
  let(:task) do
    task = double(:task).as_null_object
    allow(task).to receive(:meth).and_return(:disable_unused_credentials)
    task
  end

  context "raw cloudformation definition" do
    let(:definition) do
      {
        security_job_disable_unused_credentials_scheduled_event: {
          type: "AWS::Events::Rule",
          properties: {
            schedule_expression: "rate(10 hours)",
            state: "ENABLED",
            targets: [{
              arn: "LAMBDA_FUNCTION_ARN",
              id: "RULE_TARGET_ID"
            }]
          }
        }
      }
    end

    it "resource" do
      resource = creator.resource # attributes
      # pp resource  # uncomment to see and debug
      expect(resource.logical_id).to eq "SecurityJobDisableUnusedCredentialsScheduledEvent"
      expect(resource.type).to eq "AWS::Events::Rule"
      properties = resource.properties
      expect(properties['ScheduleExpression']).to eq "rate(10 hours)"
    end
  end
end

