require "spec_helper"

describe Jets::Job::Task do

  context "rate used" do
    it "schedule_expression" do
      task = Jets::Job::Task.new(HardJob, "dig", rate: "1 minute")
      expect(task.schedule_expression).to eq("rate(1 minute)")
    end
  end

  context "cron used" do
    it "schedule_expression" do
      task = Jets::Job::Task.new(HardJob, "dig", cron: "*/5 * * * ? *")
      expect(task.schedule_expression).to eq("cron(*/5 * * * ? *)")
    end
  end
end
