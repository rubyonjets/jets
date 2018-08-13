class Jets::WelcomeController < Jets::Controller::Base
  layout false
  internal true

  # # Use python until ruby support is added.
  # python :index

  if Jets::Commands::Build.poly_only?
    # Use python if poly only so we don't have to upload rubuy
    python :index
  else
    # TODO: When ruby support is relesed, switch to it only.
    def index
      homepage = "#{Jets.root}public/index.html"
      if File.exist?(homepage)
        render file: homepage
      else
        render plain: "The public/index.html file does not exist but the root route in config/routes.rb routes to this file.  You probably want to update the root route."
      end
    end
  end
end
