class PostsController < ApplicationController
  def index
    # puts "Post.table_name #{Post.table_name.inspect}"
    # posts = Post.scan # should not use scan for production
    # render json: {action: "index", posts: posts}

    render json: {"test": 1}

    # Disable until ruby 2.4
    # render template: "posts/index"
  end

  def new
    puts "event: #{event.inspect}"
    puts "context: #{context.inspect}"
    puts "params #{params.inspect}"
    render json: {action: "new"}
  end

  def show
    raise "my kids"
    puts "Post.table_name #{Post.table_name.inspect}"
    puts "params #{params.inspect}"
    post = Post.find(params[:id])
    puts "post #{post.inspect}"
    render json: {action: "show", post: post}
  end

  def create
    attrs = {title: params[:title], desc: params[:desc]}
    attrs[:id] = params[:id] if params[:id]
    post = Post.new(attrs)
    post.replace
    render json: {action: "create", post: post}
  end

  def edit
    post = Post.find(params[:id])
    render json: {action: "edit", post: post}
  end

  def update
    post = Post.find(params[:id])
    post.attrs = {title: params[:title], desc: params[:desc]}
    post.replace
    render json: {action: "update", post: post}
  end

  def delete
    Post.delete(params[:id])
    render json: {action: "delete"}
  end
end
