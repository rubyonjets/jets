class Jets::WelcomeController < Jets::Controller::Base
  layout false
  internal true

  python :index
  # TODO: Leave ruby implementation here, switch to it when ruby lambda is supported
  # def index
  #   homepage = "#{Jets.root}public/index.html"
  #   if File.exist?(homepage)
  #     render file: homepage
  #   else
  #     render plain: "The public/index.html file does not exist but the root route in config/routes.rb routes to this file.  You probably want to update the root route."
  #   end
  # end
end
