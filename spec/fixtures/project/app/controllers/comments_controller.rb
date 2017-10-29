class CommentsController < Jets::BaseController
  def hot
    render json: {a: "hot"}
  end
end
