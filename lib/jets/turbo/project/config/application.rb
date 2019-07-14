Jets.application.configure do
  config.project_name = "project"
  config.mode = "api"
  config.controllers.default_protect_from_forgery = false
end
