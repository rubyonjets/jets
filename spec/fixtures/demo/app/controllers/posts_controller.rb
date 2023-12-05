class PostsController < ApplicationController
  def index
    posts = Post.scan # should not use scan for production
    session[:foo] = "barbar"
    render json: {action: "index", posts: posts}
  end

  def new
    render json: params.merge(action: "new")
  end

  def show
    post = Post.find(params[:id])
    render json: {action: "show", post: post}
  end

  def create
    render json: {action: "create", event: event}
  end

  def edit
    post = Post.find(params[:id])
    render json: {action: "edit", post: post}
  end

  def update
    post = Post.find(params[:id])
    post.attrs(title: params[:title], desc: params[:desc])
    post.replace
    render json: {action: "update", post: post}
  end

  def delete
    Post.delete(params[:id])
    render json: {action: "delete"}
  end
end
