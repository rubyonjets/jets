# Simple initial implementation of a prewarmer
class Jets::PreheatJob < ApplicationJob
  enabled = Jets.config.prewarm.enabled
  enabled = enabled.nil? ? true : enabled # defaults to enabled
  concurrency = Jets.config.prewarm.concurrency || 1
  prewarm_rate = Jets.config.prewarm.rate || '30 minutes'
  torching = enabled && concurrency > 1
  warming = enabled && concurrency == 1

  class_timeout 30
  class_memory 1024

  torching ? rate(prewarm_rate) : disable(true)
  def torch
    threads = []
    concurrency.times do
      threads << Thread.new do
        # intentionally calling remote lambda for concurrency
        # avoid passing the _prewarm=1 flag because we want the job to do the work
        # So do not use Jets::Preheat.warm(function_name) here
        function_name = "jets-preheat_job-warm"
        Jets::Commands::Call.new(function_name, '{}').run unless ENV['TEST']
      end
    end
    threads.each { |t| t.join }
    "Finished prewarming your application with a concurrency of #{concurrency}."
  end

  warming ? rate(prewarm_rate) : disable(true)
  def warm
    Jets::Preheat.warm_all
  end
end
