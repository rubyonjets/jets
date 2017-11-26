require "jets"
Jets.boot

def update(event, context)
  PostsController.new(event, context).update
end

