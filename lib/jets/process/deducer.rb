# Jets::Process::Deducer class figures out information that allows the
# controller or job to be called. Sme key methods for deducer:
#
#   application_path - full path to the application_* class. IE: #{Jets.root}app/controllers/application_controller.rb
#   code - code to instance eval.  IE: PostsController.new(event, context).index
#   path - full path to the app code. IE: #{Jets.root}app/controllers/posts_controller.rb
#
class Jets::Process
  class Deducer
    def initialize(handler)
      @handler = handler # handlers/controllers/posts.show
      # @handler_path: "handlers/controllers/posts"
      # @handler_method: "show"
      @handler_path, @handler_method = @handler.split('.')
    end

    # process_type is key. It can be either "controller" or "job". It is used to
    # deduce the rest of the methods: code, path, application_path.
    def process_type
      @handler.split('/')[1].singularize # controller or job
    end

    def code
      regexp = Regexp.new(".*handlers/#{process_type.pluralize}/")
      # Example regexp:
      #   /.*handlers\/controllers\//
      #   /.*handlers\/jobs\//
      underscored_class_name = @handler_path.sub(regexp, "") + "_#{process_type}"
      # Example underscored_class_name:
      #   underscored_class_name: posts_controller
      #   underscored_class_name: hard_job
      class_name = underscored_class_name.camelize # PostsController
      code = %|#{class_name}.process(event, context, "#{@handler_method}")|

      code
      # code: "PostsController.new(event, context, meth: "show").show"
      # code: "HardJob.new(event, context, meth: "dig").dig"
    end

    # Input: @handler_path: handlers/jobs/hard_job.rb
    # Output: #{Jets.root/app/jobs/hard_job.rb
    def path
      Jets.root.to_s + @handler_path.sub("handlers", "app") + "_#{process_type}.rb"
    end

    # Examples:
    #   #{Jets.root}app/controllers/application_controller"
    #   #{Jets.root}app/jobs/application_job"
    def application_path
      "#{Jets.root}app/#{process_type.pluralize}/application_#{process_type}"
    end
  end
end
