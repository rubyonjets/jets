Jets.application.configure do
  config.project_name = "project"
  # config.env_extra = 2 # Optional. Any value works: 1,2,abc,xyz
    # Allows creation of multiple instances of env.
  config.cors = true
  config.autoload_paths = %w[
                            app/controllers
                            app/models
                            app/jobs
                            app/rules
                            app/helpers
                          ]
  config.extra_autoload_paths = []

  # function properties defaults
  config.function = ActiveSupport::OrderedOptions.new
  config.function.timeout = 10
  # default memory setting based on:
  # https://medium.com/epsagon/how-to-make-lambda-faster-memory-performance-benchmark-be6ebc41f0fc
  config.function.memory_size = 1536
end

