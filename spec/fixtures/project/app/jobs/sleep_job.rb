class SleepJob < ApplicationJob
  def perform(seconds=5, message="test message")
    seconds = 0 if ENV['TEST']
    # puts("SleepJob started.  Will sleep for #{seconds} seconds.")
    sleep seconds
    # puts("SleepJob message: #{message}")
    {work: "done"}
  end
end
