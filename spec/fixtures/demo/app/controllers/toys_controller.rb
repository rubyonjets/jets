class ToysController < ApplicationController
  before_action :set_toy, only: [:show, :edit, :update, :delete]
  authorization_scopes %w[create delete]

  # GET /toys
  def index
    @toys = Toy.all
  end

  # GET /toys/1
  def show
  end

  # GET /toys/new
  def new
    @toy = Toy.new
  end

  # GET /toys/1/edit
  def edit
  end

  # POST /toys
  def create
    @toy = Toy.new(toy_params)

    if @toy.save
      redirect_to "/toys/#{@toy.id}"
    else
      render :new
    end
  end

  # PUT /toys/1
  def update
    if @toy.update(toy_params)
      redirect_to "/toys/#{@toy.id}"
    else
      render :edit
    end
  end

  # DELETE /toys/1
  def delete
    @toy.destroy
    if request.xhr?
      render json: {success: true}
    else
      redirect_to "/toys"
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_toy
    @toy = Toy.find(params[:id])
  end

  def toy_params
    params[:toy]
  end
end
