# Simple initial implementation of a prewarmer
class Jets::PreheatJob < ApplicationJob
  enabled = Jets.config.preheat.enabled
  ENABLED = enabled.nil? ? true : enabled # defaults to enabled
  CONCURRENCY = Jets.config.preheat.concurrency || 1
  RATE = Jets.config.preheat.rate || '30 minutes'

  class_timeout 300
  class_memory 3008

  torching = ENABLED && CONCURRENCY > 1
  warming = ENABLED && CONCURRENCY == 1

  rate(RATE)
  state(torching ? "ENABLED" : "DISABLED")
  def torch
    threads = []
    CONCURRENCY.times do
      threads << Thread.new do
        # intentionally calling remote lambda for concurrency
        # avoid passing the _prewarm=1 flag because we want the job to do the work
        function_name = "jets-preheat_job-warm"
        Jets::Commands::Call.new(function_name, '{}', @options).run unless ENV['TEST']
      end
    end
    threads.each { |t| t.join }
  end

  rate(RATE)
  state(warming ? "ENABLED" : "DISABLED")
  def warm
    Jets::Preheat.warm_all
  end
end
