describe Jets::Job::Base do
  let(:null) { double(:null).as_null_object }

  # by the time the class is finished loading into memory the rate and
  # cron configs will have been loaded so we can use them later to configure
  # the lambda functions
  context HardJob do
    it "definitions" do
      definitions = HardJob.all_public_definitions.keys
      expect(definitions).to eq [:dig, :drive, :lift]

      dig_definition = HardJob.all_public_definitions[:dig]
      expect(dig_definition).to be_a(Jets::Lambda::Definition)

      drive_definition = HardJob.all_public_definitions[:lift]
      expect(drive_definition).to be_a(Jets::Lambda::Definition)
    end

    it "definitions contains flatten Array structure" do
      definitions = HardJob.definitions
      expect(definitions.first).to be_a(Jets::Lambda::Definition)

      definition_names = definitions.map(&:name)
      expect(definition_names).to eq(HardJob.all_public_definitions.keys)
    end

    it "perform_now" do
      resp = HardJob.perform_now(:dig, {})
      expect(resp).to eq(done: "digging")
    end

    it "perform_later" do
      allow(Jets::Commands::Call::Caller).to receive(:new).and_return(null)
      allow(HardJob).to receive(:on_lambda?).and_return(true)
      HardJob.perform_later(:dig, {})
      expect(Jets::Commands::Call::Caller).to have_received(:new)
    end
  end

  context EasyJob do
    it "definitions" do
      definitions = EasyJob.all_public_definitions.keys
      expect(definitions).to eq [:sleep]
    end
  end

  describe "s3_event" do
    context 'configuration' do
      it "allows custom sns subscription properties" do
        class HardJob
          s3_event("s3-bucket", sns_subscription_properties: { FilterPolicy: { field: [{ "prefix": "some_value" }] }.to_json })
          def process_s3_event;end
        end

        process_s3_event    = HardJob.all_public_definitions[:process_s3_event]
        definition          = process_s3_event.associated_resources.first.definition.detect { |d| d.try(:dig, "{namespace}SnsSubscription", :Type) == "AWS::SNS::Subscription" }
        expected_properties = {
          :Endpoint=>"!GetAtt {namespace}LambdaFunction.Arn",
          :Protocol=>"lambda",
          :FilterPolicy=>"{\"field\":[{\"prefix\":\"some_value\"}]}",
          :TopicArn=>"!Ref S3BucketSnsTopic"
        }

        expect(definition.dig("{namespace}SnsSubscription", :Type)).to eq("AWS::SNS::Subscription")
        expect(definition.dig("{namespace}SnsSubscription", :Properties)).to eq(expected_properties)
      end
    end

    context "s3 upload" do
      it "s3_events" do
        event = json_file("spec/fixtures/dumps/sns/s3_upload.json")
        job = HardJob.new(event, {}, :dig)
        expect(job.s3_events.first).to include("eventName")
        expect(job.s3_events.first[:eventName]).to eq "ObjectCreated:Put"
        expect(job.s3_events?).to eq true

        expect(job.s3_objects.first.key?("key")).to be true
        expect(job.s3_objects.first[:key]).to eq "myfolder/subfolder/test.txt"
        expect(job.s3_objects?).to eq true
      end
    end
  end

  context 'sns_event' do
    it 'sns_events' do
      event = json_file("spec/fixtures/dumps/sns/sns_event.json")
      job = HardJob.new(event, {}, :dig)
      expect(job.sns_events.first.key?("body")).to be true
      expect(job.sns_events.first[:body]).to eq "This is a sns hard job"
    end
  end

  context 'sqs_event' do
    it 'sqs_events' do
      event = json_file("spec/fixtures/dumps/sqs/sqs_event.json")
      job = HardJob.new(event, {}, :dig)
      expect(job.sqs_events.first.key?("message")).to be true
      expect(job.sqs_events.first[:message]).to eq "This is a hard job"
    end
  end

  context "cloudwatch log event" do
    it "log_event" do
      event = json_file("spec/fixtures/dumps/logs/log_event.json")
      job = HardJob.new(event, {}, :dig)
      # uncomment to debug
      # puts JSON.pretty_generate(job.event)
      # puts JSON.pretty_generate(job.log_event)

      data = job.log_event
      expect(data["messageType"]).to eq "DATA_MESSAGE"
      expect(data.key?("logEvents")).to be true
    end
  end

  context "kinesis log event" do
    it "kinesis_data" do
      event = json_file("spec/fixtures/dumps/kinesis/records.json")
      job = HardJob.new(event, {}, :dig)
      # uncomment to debug
      # puts JSON.pretty_generate(job.event)
      # puts JSON.pretty_generate(job.kinesis_data)

      expect(job.event.key?("Records")).to be true
      expect(job.kinesis_data).to eq(["hello world", "hello world", "hello world"])
    end
  end
end