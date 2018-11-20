class PostsController < ApplicationController
  class_timeout 22
  class_iam_policy("lambda:*", "logs:*")

  timeout 18
  def index
    # puts "Post.table_name #{Post.table_name.inspect}"
    posts = Post.scan # should not use scan for production
    session[:foo] = "barbar"
    render json: {action: "index", posts: posts}
  end

  iam_policy("lambda:*", "ec2:*")
  def new
    render json: params.merge(action: "new")
  end

  managed_iam_policy "AmazonEC2ReadOnlyAccess"
  def show
    post = Post.find(params[:id])
    # puts "post #{post.inspect}"
    render json: {action: "show", post: post}
  end

  def create
    render json: {action: "create", event: event}
    # attrs = {title: params[:title], desc: params[:desc]}
    # attrs[:id] = params[:id] if params[:id]
    # post = Post.new(attrs)
    # post.replace
    # render json: {action: "create", post: post}
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
