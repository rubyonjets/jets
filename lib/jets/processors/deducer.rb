# Jets::Processors::Deducer class figures out information that allows the
# controller or job to be called. Sme key methods for deducer:
#
#   code - code to instance eval.  IE: PostsController.new(event, context).index
#   path - full path to the app code. IE: #{Jets.root}app/controllers/posts_controller.rb
#
class Jets::Processors::Deducer
  def initialize(handler)
    @handler = handler # handlers/controllers/posts.show
    # @handler_path: "handlers/controllers/posts"
    # @handler_method: "show"
    @handler_path, @handler_method = @handler.split('.')
  end

  def code
    # code: "PostsController.process(event, context, meth: "show")"
    # code: "HardJob.process(event, context, meth: "dig")"
    %|#{class_name}.process(event, context, "#{@handler_method}")|
  end

  # Input: @handler_path: handlers/jobs/hard_job.rb
  # Output: #{Jets.root/app/jobs/hard_job.rb
  def path
    @handler_path.sub("handlers", "app") + ".rb"
  end

  # process_type is key. It can be either "controller" or "job". It is used to
  # deduce the rest of the methods: code, path.
  def process_type
    if shared?
      "function" # all app/shared/functions are always function process_type
    else
      @handler.split('/')[1].singularize # controller, job, rule, etc
    end
  end

  def shared?
    @handler.include?("/shared/functions")
  end

  # Example underscored_class_name:
  #   class_name = underscored_class_name
  #   class_name = class_name # PostsController
  def class_name
    regexp = shared? ?
      Regexp.new(".*handlers/shared/functions/") :
      Regexp.new(".*handlers/#{process_type.pluralize}/")

    # Example regexp:
    #   /.*handlers\/controllers\//
    #   /.*handlers\/jobs\//
    class_name = @handler_path.sub(regexp, "")
    # Example class names:
    #   posts_controller
    #   hard_job
    #   hello
    #   hello_function

    class_name.camelize
  end

  def load_class
    Jets::Klass.from_path(path)
  end
end
