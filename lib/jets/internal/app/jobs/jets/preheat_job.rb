# Simple initial implementation of a prewarmer
class Jets::PreheatJob < ApplicationJob
  enabled = Jets.config.prewarm.enabled
  ENABLED = enabled.nil? ? true : enabled # defaults to enabled
  CONCURRENCY = Jets.config.prewarm.concurrency || 1
  RATE = Jets.config.prewarm.rate || '30 minutes'
  torching = ENABLED && CONCURRENCY > 1
  warming = ENABLED && CONCURRENCY == 1

  class_timeout 300
  class_memory 3008

  # Creating all jobs upfront to avoid the Jets Warning:
  #   created without a rate or cron expression
  # The private doesn't currently work after the method.
  # TODO: make private work with a silencing of the warning check.
  rate(RATE)
  state(torching ? "ENABLED" : "DISABLED")
  def torch
    threads = []
    CONCURRENCY.times do
      threads << Thread.new do
        # intentionally calling remote lambda for concurrency
        # avoid passing the _prewarm=1 flag because we want the job to do the work
        function_name = "jets-preheat_job-warm"
        Jets::Commands::Call.new(function_name, '{}').run unless ENV['TEST']
      end
    end
    threads.each { |t| t.join }
    "Finished prewarming your application with a concurrency of #{CONCURRENCY}."
  end

  rate(RATE)
  state(warming ? "ENABLED" : "DISABLED")
  def warm
    Jets::Preheat.warm_all
  end
end
