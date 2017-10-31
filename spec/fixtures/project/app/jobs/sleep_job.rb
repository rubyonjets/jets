class SleepJob < ApplicationJob
  def perform
    seconds = ENV['TEST'] ? 0 : 5
    puts("SleepJob started.  Will sleep for #{seconds} seconds.") unless ENV['TEST']
    sleep seconds
    puts("SleepJob event: #{event.inspect}") unless ENV['TEST']
    {work: "done"}
  end
end
