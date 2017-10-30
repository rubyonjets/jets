# Deduces the path and method from the handler. Example:
#
#   deducer = ControllerDeducer.new("handlers/controllers/posts.create")
#   deducer.path # "./app/controllers/posts_controller.rb"
#   deducer.code # PostsController.new(event, context).create
#
# You can then use the deduction to require and run the code like so:
#
#   require "./app/controllers/posts_controller.rb"
#   result = PostsController.new(event, context).create
#
class Jets::Process::Deducer
  class ControllerDeducer < BaseDeducer
    def path
      path = Jets.root + @handler_path.sub("handlers", "app") + "_controller.rb"
    end

    def application_path
      "#{Jets.root}app/controllers/application_controller"
    end

    def code
      controller_name = @handler_path.sub(%r{.*handlers/controllers/}, "") + "_controller" # posts_controller
      controller_class = controller_name.camelize # PostsController
      code = "#{controller_class}.new(event, context).#{@handler_method}" # PostsController.new(event, context).create
    end
  end
end