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

end
