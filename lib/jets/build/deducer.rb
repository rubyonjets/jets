# Build::Deducers figure out required values to create the node shim
class Jets::Build
  class Deducer
    # Example paths:
    #   app/controllers/posts_controller.rb
    #   app/jobs/hard_job.rb
    attr_reader :path
    def initialize(path)
      @path = path
    end

    # process_type is key, it will either "controller" or "job".
    # It is used to deduce class_name, etc.
    # We get the process_type from the path.
    # Example paths:
    #   app/controllers/posts_controller.rb
    #   app/jobs/hard_job.rb
    def process_type
      @path.split('/')[1].singularize # controller or job
    end

    # PostsController
    def class_name
      @path.sub(%r{app/(\w+)/},'').sub('.rb','').classify
    end

    # Returns the public methods of the child_class.
    # Example: [:create, :update]
    def functions
      # Example: require "./app/controllers/posts_controller.rb"
      require_path = @path.starts_with?('/') ? @path : "#{Jets.root}#{@path}"
      require require_path

      klass = class_name.constantize
      klass.lambda_functions
    end

    # This gets called in the node shim js template
    def handler_for(method)
      # process_type: controller or job
      regexp = Regexp.new("#{process_type.camelize}$")
      # module_name: posts (controller) or sleep (job)
      module_name = class_name.sub(regexp, '').underscore
      "handlers/#{process_type.pluralize}/#{module_name}.#{method}"
    end

    # Example return: "handlers/controllers/posts.js"
    def js_path
      @path.sub("app", "handlers").sub("_#{process_type}.rb", ".js")
    end
  end
end
