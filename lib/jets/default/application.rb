Jets.application.configure do
  config.project_name = "proj"
  # config.env_extra = 2 # Optional. Any value works: 1,2,abc,xyz
    # Allows creation of multiple instances of env.
  config.cors = true
  config.autoload_paths = %w[
                            app/controllers
                            app/models
                            app/jobs
                            app/helpers
                          ]
  config.extra_autoload_paths = []

  # function properties defaults
  config.function = ActiveSupport::OrderedOptions.new
  config.function.timeout = 10
  config.function.runtime = "nodejs6.10"
  config.function.memory_size = 1536
end

