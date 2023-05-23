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

  context "s3 upload" do
    it "s3_event" do
      event = json_file("spec/fixtures/dumps/sns/s3_upload.json")
      job = HardJob.new(event, {}, :dig)
      # uncomment to debug
      # puts JSON.pretty_generate(job.event)
      # puts JSON.pretty_generate(job.s3_event)
      # puts JSON.pretty_generate(job.s3_object)

      expect(job.s3_event.key?("Records")).to be true

      expect(job.s3_object.key?("key")).to be true
      expect(job.s3_object[:key]).to eq "myfolder/subfolder/test.txt"
    end
  end

  context 'sns_event' do
    it 'sns_event_payload' do
      event = json_file("spec/fixtures/dumps/sns/sns_event.json")
      job = HardJob.new(event, {}, :dig)
      # uncomment to debug
      # puts JSON.pretty_generate(job.event)
      # puts JSON.pretty_generate(job.sns_event_payload)


      expect(job.sns_event_payload.key?("body")).to be true
      expect(job.sns_event_payload[:body]).to eq "This is a sns hard job"
    end
  end

  context 'sqs_event' do
    it 'sns_event_payload' do
      event = json_file("spec/fixtures/dumps/sqs/sqs_event.json")
      job = HardJob.new(event, {}, :dig)
      # uncomment to debug
      # puts JSON.pretty_generate(job.event)
      # puts JSON.pretty_generate(job.sqs_event_payload)


      expect(job.sqs_event_payload.key?("message")).to be true
      expect(job.sqs_event_payload[:message]).to eq "This is a hard job"
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