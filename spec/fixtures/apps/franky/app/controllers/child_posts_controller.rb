class ChildPostsController < PostsController
  def index
    render json: "test"
  end

  def foobar
    render plain: "foobar"
  end
end