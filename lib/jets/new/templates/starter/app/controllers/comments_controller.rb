class CommentsController < ApplicationController
  def hot
    render json: {a: "hot"}
  end
end
