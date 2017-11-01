require "jets"
Jets.boot
require "app/functions/posts_controller"

def update(event, context)
  PostsController.new(event, context).update
end

