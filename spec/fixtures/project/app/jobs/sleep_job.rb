class SleepJob < ApplicationJob
  def perform(seconds=5, message="test message")
    puts("SleepJob started.  Will sleep for #{seconds} seconds.")
    sleep seconds
    puts("SleepJob message: #{message}")
    {job_completed: true}
  end
end
