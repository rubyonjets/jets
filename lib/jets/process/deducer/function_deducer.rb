# Deduces the path and method from the handler. Example:
#
#   deducer = ControllerDeducer.new("handlers/functions/posts.create")
#   deducer.path # "./app/controllers/posts_controller.rb"
#   deducer.code # PostsController.new(event, context).create
#
# You can then use the deduction to require and run the code like so:
#
#   require "./app/controllers/posts_controller.rb"
#   result = PostsController.new(event, context).create
#
class Jets::Process::Deducer
  class FunctionDeducer < BaseDeducer
    def path
      # TODO: implement FunctionDeducer.path
    end

    def code
      # TODO: implement FunctionDeducer.code
    end

    # Deduces the path and method from the handler. Example:
    #
    #   ProcessorDeducer.new("handlers/functions/posts.create").function
    #     => {path: "app/functions/posts.rb", code: "create(event, context)"}
    #
    # Summary:
    #
    # Input:
    #   handler: handlers/functions/posts.create
    # Output:
    #   path: app/functions/posts.rb
    #   code: create(event, context) # code to instance_eval
    #
    # Returns: {path: path, code: code}
    # def function
    #   path, meth = @handler.split('.')
    #   path = Jets.root + path.sub("handlers", "app") + ".rb"
    #   code = "#{meth}(event, context)"
    #   {path: path, code: code}
    # end

  end
end