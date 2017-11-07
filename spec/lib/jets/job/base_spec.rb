require "spec_helper"

describe Jets::Job::Base do
  # by the time the class is finished loading into memory the rate and
  # cron configs will have been loaded so we can use them later to configure
  # the lambda functions
  context HardJob do
    it "tasks" do
      tasks = HardJob.tasks.keys
      expect(tasks).to eq [:dig, :drive, :lift]

      dig_task = HardJob.tasks[:dig]
      expect(dig_task).to be_a(Jets::Job::Task)
      expect(dig_task.schedule_expression).to eq "rate(1 minute)"

      drive_task = HardJob.tasks[:lift]
      expect(drive_task).to be_a(Jets::Job::Task)
      expect(drive_task.schedule_expression).to eq "cron(0 */12 * * ? *)"
    end

    it "all_tasks flattens structure into Array from the Hash values" do
      all_tasks = HardJob.all_tasks
      expect(all_tasks.first).to be_a(Jets::Job::Task)

      all_task_names = all_tasks.map(&:name)
      expect(all_task_names).to eq(HardJob.tasks.keys)
    end
  end

  context EasyJob do
    it "all_tasks" do
      tasks = EasyJob.tasks.keys
      expect(tasks).to eq [:sleep]
    end
  end

end
