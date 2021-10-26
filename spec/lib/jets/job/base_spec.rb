describe Jets::Job::Base do
  let(:null) { double(:null).as_null_object }

  # by the time the class is finished loading into memory the rate and
  # cron configs will have been loaded so we can use them later to configure
  # the lambda functions
  context HardJob do
    it "tasks" do
      tasks = HardJob.all_public_tasks.keys
      expect(tasks).to eq [:dig, :drive, :lift]

      dig_task = HardJob.all_public_tasks[:dig]
      expect(dig_task).to be_a(Jets::Lambda::Task)

      drive_task = HardJob.all_public_tasks[:lift]
      expect(drive_task).to be_a(Jets::Lambda::Task)
    end

    it "tasks contains flatten Array structure" do
      tasks = HardJob.tasks
      expect(tasks.first).to be_a(Jets::Lambda::Task)

      task_names = tasks.map(&:name)
      expect(task_names).to eq(HardJob.all_public_tasks.keys)
    end

    it "perform_now" do
      resp = HardJob.perform_now(:dig, {})
      expect(resp).to eq(done: "digging")
    end

    it "perform_later" do
      allow(Jets::Commands::Call).to receive(:new).and_return(null)
      allow(HardJob).to receive(:on_lambda?).and_return(true)
      HardJob.perform_later(:dig, {})
      expect(Jets::Commands::Call).to have_received(:new)
    end
  end

  context EasyJob do
    it "tasks" do
      tasks = EasyJob.all_public_tasks.keys
      expect(tasks).to eq [:sleep]
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