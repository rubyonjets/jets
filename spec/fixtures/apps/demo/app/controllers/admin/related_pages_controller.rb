class Admin::RelatedPagesController < ApplicationController
  def index
    render json: {"action": "index"}
  end
end
