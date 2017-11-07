class PostsController < ApplicationController
  def index
    puts "Post.table_name #{Post.table_name.inspect}"
    posts = Post.scan # should not use scan for production
    render json: {action: "index", posts: posts}, status: 200
  end

  def new
    puts "event: #{event.inspect}"
    puts "context: #{context.inspect}"
    render json: {action: "new"}, status: 200
  end

  def show
    post = Post.find(params[:id])
    render json: {action: "show", post: post}, status: 200
  end

  def create
    attrs = {title: params[:title], desc: params[:desc]}
    attrs[:id] = params[:id] if params[:id]
    post = Post.new(attrs)
    post.replace
    render json: {action: "create", post: post}, status: 200
  end

  def edit
    post = Post.find(params[:id])
    render json: {action: "edit", post: post}, status: 200
  end

  def update
    post = Post.find(params[:id])
    post.attrs = {title: params[:title], desc: params[:desc]}
    post.replace
    render json: {action: "update", post: post}, status: 200
  end

  def delete
    Post.delete(params[:id])
    render json: {action: "delete"}, status: 200
  end
end
