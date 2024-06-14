class Jets::PreheatJob < ApplicationJob
  ENABLED = Jets.config.prewarm.enable
  CONCURRENCY = Jets.config.prewarm.concurrency
  PREWARM_RATE = Jets.config.prewarm.rate
  torching = ENABLED && CONCURRENCY > 1
  warming = ENABLED && CONCURRENCY == 1

  class_timeout 30
  class_memory 1024
  class_iam_policy(Jets::Application.preheat_job_iam_policy)

  rate(PREWARM_RATE) if torching
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
        Jets::Commands::Call.new(function_name, event_json, options).run unless Jets.env.test?
      end
    end
    threads.each { |t| t.join }
    "Finished prewarming your application with a concurrency of #{CONCURRENCY}."
  end

  rate(PREWARM_RATE) if warming
  def warm
    options = call_options(event[:quiet])
    Jets::Preheat.warm_all(options)
    "Finished prewarming your application."
  end

  class << self
    # Can use this to prewarm post deploy
    def prewarm!
      meth = CONCURRENCY > 1 ? :torch : :warm
      perform_now(meth, quiet: true)
    end
  end

private
  def call_options(quiet)
    options = {}
    options.merge!(mute: true, mute_output: true) if quiet
    options
  end
end
