require "spec_helper"

describe Jets::Job::Base do
  # by the time the class is finished loading into memory the rate and
  # cron configs will have been loaded so we can use them later to configure
  # the lambda functions
  it "all_tasks" do
    pp HardJob.all_tasks
    pp EasyJob.all_tasks
  end

end
