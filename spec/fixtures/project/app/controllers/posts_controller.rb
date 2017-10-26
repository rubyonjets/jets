class PostsController < Lam::BaseController
  def create
    # render text: "test2" # more consistent for web controllers

    # render returns Lamba Proxy struture for web requests
    render json: event.merge(a: "create"), status: 200
  end

  def update
    render json: event.merge(a: "update"), status: 200
  end
end
