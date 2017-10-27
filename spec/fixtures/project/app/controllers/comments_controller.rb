class CommentsController < Jets::BaseController
  def index
    render json: event.merge(a: "index")
  end

  def edit
    render json: event.merge(a: "edit")
  end
end
