describe Jets::ResourceCreator do
  let(:creator) { Jets::ResourceCreator.new(definition, task) }
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

    it "pasalizes the keys" do
      resource = creator.resource
      # pp resource  # uncomment to see and debug
      logical_id = resource.keys.first
      expect(logical_id).to eq "SecurityJobDisableUnusedCredentialsScheduledEvent"
    end

    it "update_values" do
      allow(creator).to receive(:replace_value).and_return("test") # stub out for testing
      result = creator.update_values("TEST")
      expect(result).to eq "test"
      result = creator.update_values(k: "TEST")
      expect(result).to eq(k: "test")
      result = creator.update_values(a: {b: "TEST"})
      expect(result).to eq(a: {b: "test"})
    end

    it "replace_placeholders" do
      resource = creator.replace_placeholders(LAMBDA_FUNCTION_ARN: "blah:arn")
      target = resource["SecurityJobDisableUnusedCredentialsScheduledEvent"]["Properties"]["Targets"].first
      expect(target["Arn"]).to eq "blah:arn"
    end
  end
end

