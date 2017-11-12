class Admin::RelatedPagesController < ApplicationController
  def index
    render json: {"action": "index"}
  end

  def list_all
    render json: {"action": "list_all"}
  end
end
