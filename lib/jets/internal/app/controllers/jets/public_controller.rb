# Works for utf8 text files.
# TODO: Add support to public_controller for binary data like images.
# Tricky because API Gateway is not respecting the Accept header in the
# same way as browsers.
class Jets::PublicController < Jets::Controller::Base
  def show
    path = Jets.root + "public" + params[:catchall]
    if path.exist?
      render file: path
    else
      render status: 404
    end
  end
end
