class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :delete]

  # GET /articles
  def index
    @articles = Article.all
  end

  # GET /articles/1
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to "/articles/#{@article.id}"
    else
      render :new
    end
  end

  # PUT /articles/1
  def update
    if @article.update(article_params)
      redirect_to "/articles/#{@article.id}"
    else
      render :edit
    end
  end

  # DELETE /articles/1
  def delete
    @article.destroy
    if request.xhr?
      render json: {success: true}
    else
      redirect_to "/articles"
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params[:article]
  end
end
