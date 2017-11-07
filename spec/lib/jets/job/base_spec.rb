require "spec_helper"

describe Jets::Job::Base do
  # by the time the class is finished loading into memory the rate and
  # cron configs will have been loaded so we can use them later to configure
  # the lambda functions
  context HardJob do
    it "all_tasks" do
      tasks = HardJob.all_tasks.keys
      expect(tasks).to eq [:dig, :drive]

      dig_task = HardJob.all_tasks[:dig]
      expect(dig_task).to be_a(Jets::Job::Task)
      expect(dig_task.schedule_expression).to eq "rate(1 minute)"

      drive_task = HardJob.all_tasks[:drive]
      expect(drive_task).to be_a(Jets::Job::Task)
      expect(drive_task.schedule_expression).to eq "cron(*/5 * * * ? *)"
    end
  end

  context EasyJob do
    it "all_tasks" do
      tasks = EasyJob.all_tasks.keys
      expect(tasks).to eq [:sleep]
    end
  end

end
