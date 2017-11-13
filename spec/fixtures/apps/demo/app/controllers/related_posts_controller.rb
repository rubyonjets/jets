class RelatedPostsController < ApplicationController
  def show
    render json: {"action": "show"}
  end
end
