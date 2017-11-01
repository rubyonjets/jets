# This deducer class figures out information that allows the controller or job call
# to be called.
#
# Classes inheriting from BaseDeducer must implement these methods:
#
#   path - full path to the app code. IE: #{Jets.root}app/controllers/posts_controller.rb
#   application_path - full path to the application_* class. IE: #{Jets.root}app/controllers/application_controller.rb
#   code - code to instance eval.  IE: PostsController.new(event, context).index
#
class Jets::Process::Deducer::BaseDeducer
  def initialize(handler)
    @handler = handler # handlers/controllers/posts.create
    # @handler_path: "handlers/controllers/posts"
    # @handler_method: "create"
    @handler_path, @handler_method = @handler.split('.')
  end
end
