class EasyJob < ApplicationJob
  rate "1 day"
  def sleep
    seconds = ENV['TEST'] ? 0 : 1
    sleep seconds
    {done: "sleeping"}
  end
end
