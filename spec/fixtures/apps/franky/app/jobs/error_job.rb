class ErrorJob < ApplicationJob
  rate "10 hours" # every 10 hours
  def break
    raise "break me"
  end
end
