# Simple initial implementation of a prewarmer
class Jets::PreheatJob < ApplicationJob
  enabled = Jets.config.prewarm.enabled
  ENABLED = enabled.nil? ? true : enabled # defaults to enabled
  CONCURRENCY = Jets.config.prewarm.concurrency || 1
  PREWARM_RATE = Jets.config.prewarm.rate || '30 minutes'
  torching = ENABLED && CONCURRENCY > 1
  warming = ENABLED && CONCURRENCY == 1

  class_timeout 30
  class_memory 1024

  unless Jets::Commands::Build.poly_only?
    torching ? rate(PREWARM_RATE) : disable(true)
    def torch
      threads = []
      CONCURRENCY.times do
        threads << Thread.new do
          # intentionally calling remote lambda for concurrency
          # avoid passing the _prewarm=1 flag because we want the job to do the work
          # So do not use Jets::Preheat.warm(function_name) here
          function_name = "jets-preheat_job-warm"
          event_json = JSON.dump(event)
          call_options = event[:quiet] ? {mute: true} : {}
          Jets::Commands::Call.new(function_name, event_json, call_options).run unless ENV['TEST']
        end
      end
      threads.each { |t| t.join }
      "Finished prewarming your application with a concurrency of #{CONCURRENCY}."
    end

    warming ? rate(PREWARM_RATE) : disable(true)
    def warm
      options = event[:quiet] ? {mute: true} : {}
      Jets::Preheat.warm_all(options)
    end
  end
end
