class CommentsController < ApplicationController
  def hot
    post = Post.find("tung")
    render json: {action: "hot", ruby: RUBY_VERSION, post: post}
  end
end
