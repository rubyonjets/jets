class CommentsController < Jets::BaseController
  def index
    puts "event #{event.inspect}"
    render json: event.merge(a: "index3"), status: 200
  end

  def edit
    render json: event.merge(a: "edit")
  end
end
