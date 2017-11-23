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
      # Example underscored_class_name:
      #   underscored_class_name: posts_controller
      #   underscored_class_name: hard_job
      class_name = underscored_class_name.camelize # PostsController
      code = %|#{class_name}.process(event, context, "#{@handler_method}")|

      code
      # code: "PostsController.new(event, context, meth: "show").show"
      # code: "HardJob.new(event, context, meth: "dig").dig"
    end

    def underscored_class_name
      regexp = Regexp.new(".*handlers/#{process_type.pluralize}/")
      # Example regexp:
      #   /.*handlers\/controllers\//
      #   /.*handlers\/jobs\//
      @handler_path.sub(regexp, "")
    end

    # Input: @handler_path: handlers/jobs/hard_job.rb
    # Output: #{Jets.root/app/jobs/hard_job.rb
    def path
      Jets.root.to_s + @handler_path.sub("handlers", "app") + ".rb"
    end

    # Examples:
    #   #{Jets.root}app/controllers/application_controller"
    #   #{Jets.root}app/jobs/application_job"
    def application_path
      "#{Jets.root}app/#{process_type.pluralize}/application_#{process_type}"
    end

    # This is only required for Jets::Lambda::Function because it the class
    # that it returns an Anonymous class that cannot be autoloaded.
    #
    # https://stackoverflow.com/questions/9363842/is-there-any-hack-to-override-a-class-name-with-custom-one
    # Object.const_set(name.capitalize, Class.new()).new()
    def define_class
      # Only required to load the class if it's an simple type of function.
      # Controllers and Jobs are autoloaded.
      return unless simple_function_type?
      # code_path: app/functions/hello.rb
      constructor = Jets::Lambda::FunctionConstructor.new(path)
      class_name = File.basename(path, '.rb').classify
      Object.const_set(class_name, constructor.build)
    end

    def simple_function_type?
      path.include?("/functions/")
    end
  end
end
