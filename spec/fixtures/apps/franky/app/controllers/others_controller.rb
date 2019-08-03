# frozen_string_literal: true

class OthersController < ApplicationController
  def catchall
    render json: {action: "all", event: event}
  end
end
