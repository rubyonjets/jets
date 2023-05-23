class PublicFilesController < ApplicationController
  def show
    path = Jets.root + "public" + params[:catchall]
    if path.exist?
      # TODO: only works for text files. Add support for binary data like images
      render file: path
    else
      render status: 404
    end
  end
end
