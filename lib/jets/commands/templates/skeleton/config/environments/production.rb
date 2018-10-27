Jets.application.configure do
  # If your app exceeds the AWS Lambda code size limit then Jets will automatically
  # enable config.ruby.lazy_load = true regardless of this setting.
  config.ruby.lazy_load = false
end