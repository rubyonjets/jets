# Build::Deducers figure out required values to create the node shim
class Jets::Builders
  class Deducer
    # Allow user to specify relative or full path. The right path gets used
    # internally. Example paths:
    #   app/controllers/posts_controller.rb
    #   app/jobs/hard_job.rb
    #   /tmp/jets/build/app_root/app/jobs/hard_job.rb
    #   /tmp/jets/build/app_root/app/functions/hello.rb
    def initialize(path)
      @full_path = full(path)
      @relative_path = relative(path)
    end

    def full(path)
      path = "#{Jets.root}#{path}" unless path.starts_with?("/")
      path
    end

    def relative(path)
      full_path = full(path)
      full_path.sub(Jets.root.to_s, "")
               .sub(/.*internal\/app/, "app")

    end

    # process_type is key, it will either "controller" or "job".
    # It is used to deduce klass, etc.
    # We get the process_type from the path.
    # Example paths:
    #   app/controllers/posts_controller.rb
    #   app/jobs/hard_job.rb
    def process_type
      @relative_path.split('/')[1].singularize # controller or job
    end

    # Returns the public methods of the child_class.
    # Example: [:create, :update]
    def functions
      # Example: require: /tmp/jets/demo/app_root/app/controllers/admin/posts_controller.rb
      class_name = @full_path.sub(/.*\/app\/\w+\//,'').sub(/\.rb/,'') # admin/posts_controller
      class_name = class_name.classify # Admin::PostsController
      # Autoload instead of require to avoid accidentallly double requiring and
      # it resulting WARNINGs when there are constants already defined
      klass = class_name.constantize # autoload

      klass.lambda_functions
    end

    # Examples: PostsController, HardJob, Hello, HelloFunction
    def klass
      @klass ||= Jets::Klass.from_path(@relative_path)
    end

    def lang(meth)
      klass.tasks.find
    end

    # This gets called in the node shim js template
    def handler_for(meth)
      # possibly not include _function
      underscored_name = @relative_path.sub(%r{app/(\w+)/},'').sub('.rb','')
      "handlers/#{process_type.pluralize}/#{underscored_name}.#{meth}"
    end

    # Example return: "handlers/controllers/posts.js"
    def js_path
      @relative_path
        .sub("app", "handlers")
        .sub(/\.rb$/, ".js")
    end
  end
end
