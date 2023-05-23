Jets.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.log_level = :info
  config.logging.event = true # useful for CloudWatch logs
  config.consider_all_requests_local       = false
  config.assets.compile = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  # config.action_mailer.default_url_options = { host: 'localhost', port: 8888 }
  # Example:
  # config.function.memory_size = 2048
end