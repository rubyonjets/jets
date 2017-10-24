class Lam::Process::Infer
  def initialize(handler)
    @handler = handler
    @project_root = ENV['PROJECT_ROOT'] || '.'
  end

  # Infers the path and method from the handler. Example:
  #
  #   InferCode.new("handlers/functions/posts.create").function
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
  def function
    path, meth = @handler.split('.')
    path = "#{@project_root}/" + path.sub("handlers", "app") + ".rb"
    code = "#{meth}(event, context)"
    {path: path, code: code}
  end

  # Infers the path and method from the handler. Example:
  #
  #   InferCode.new("handlers/controllers/posts.create").controller
  #     => {path: "controllers/posts_controller.rb", code: "create"}
  #
  # Summary:
  #
  # Input:
  #   handler: handlers/controllers/posts.create
  # Output:
  #   path: app/controllers/posts_controller.rb
  #   code: create # code to instance_eval
  #
  # Returns: {path: path, code: code}
  def controller
    handler_path, meth = @handler.split('.')

    path = "#{@project_root}/" + handler_path.sub("handlers", "app") + "_controller.rb"

    controller_name = handler_path.sub(%r{.*handlers/controllers/}, "") + "_controller" # posts_controller
    controller_class = controller_name.split('_').collect(&:capitalize).join # PostsController
    code = "#{controller_class}.new(event, context).#{meth}" # PostsController.new(event, context).create

    {path: path, code: code}
  end
end
