class OthersController < ApplicationController
  def catchall
    render json: {action: "all", event: event}
  end
end
