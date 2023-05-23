Jets.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.jets_controller.perform_caching = false
  config.jets_controller.enable_fragment_cache_logging = false

  config.action_dispatch.show_exceptions = true

  # Enable/disable caching. By default caching is disabled.
  if Jets.root.join("tmp/caching-dev.txt").exist?
    config.jets_controller.perform_caching = true
    config.cache_store = :memory_store
  else
    config.jets_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  # config.action_mailer.default_url_options = { host: 'localhost', port: 8888 }

  config.logging.event = false # useful for CloudWatch logs
  # Example:
  # config.function.memory_size = 1536
end