class Jets::PreheatJob < ApplicationJob
  enabled = Jets.config.prewarm.enabled
  ENABLED = enabled.nil? ? true : enabled # defaults to enabled
  CONCURRENCY = Jets.config.prewarm.concurrency || 2
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
          # avoid passing the _prewarm=1 flag because we want the PreheatJob#warm
          # to run it's normal workload.
          # Do not use Jets::Preheat.warm(function_name) here as that passes the _prewarm=1.
          function_name = "jets-preheat_job-warm"
          event_json = JSON.dump(event)
          options = call_options(event[:quiet])
          Jets::Commands::Call.new(function_name, event_json, options).run unless ENV['TEST']
        end
      end
      threads.each { |t| t.join }
      "Finished prewarming your application with a concurrency of #{CONCURRENCY}."
    end

    warming ? rate(PREWARM_RATE) : disable(true)
    def warm
      options = call_options(event[:quiet])
      Jets::Preheat.warm_all(options)
      "Finished prewarming your application."
    end

  private
    def call_options(quiet)
      options = {}
      options.merge!(mute: true, mute_output: true) if quiet
      # All the methods in this Job class leads to Jets::Commands::Call.
      # This is true for the Jets::Preheat.warm_all also.
      # These jobs delegate out to Lambda function calls. We do not need/want
      # the invocation type: RequestResponse in this case.
      options.merge!(invocation_type: "Event")
      options
    end
  end
end
