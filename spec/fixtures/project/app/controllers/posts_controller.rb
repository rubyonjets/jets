class PostsController < Jets::BaseController
  def index
    # render returns Lambda Proxy struture for web requests
    render json: {a: "index"}, status: 200
  end

  def show
    render json: {a: "show"}, status: 200
  end

  def create
    render json: {a: "create"}, status: 200
  end

  def edit
    render json: {a: "edit"}, status: 200
  end

  def update
    render json: {a: "update"}, status: 200
  end

  def delete
    render json: {a: "delete"}, status: 200
  end
end
