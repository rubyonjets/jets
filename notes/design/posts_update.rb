require "jets"
Jets.boot
require "app/controllers/posts_controller"

def update(event, context)
  PostsController.new(event, context).update
end
