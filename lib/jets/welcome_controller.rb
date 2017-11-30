class Jets::WelcomeController < Jets::Controller::Base
  layout false

  def index
    homepage = "#{Jets.root}public/index.html"
    if File.exist?(homepage)
      render file: homepage
    else
      render plain: "The public/index.html file does not exist but the root route in config/routes.rb has not been updated.  You probably want to update the root route."
    end
  end
end
