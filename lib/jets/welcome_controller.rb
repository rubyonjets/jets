class Jets::WelcomeController < Jets::Controller::Base
  layout false

  def index
    render text: "welcome text"
  end
end
