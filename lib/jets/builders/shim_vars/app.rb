# Jets::Builders::ShimVars::Shared.new(path)
#
#   @vars.functions.each do |function_name|
#     @vars.handler_for(function_name)
#   end
#
# Implements:
#
#   functions: IE [:index, :show]
#   handler_for(function_name): IE handlers/controllers/posts_controller.index
#   dest_path: IE: handlers/controllers/posts_controller.js
#
module Jets::Builders::ShimVars
  class App < Base
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
    # IE handlers/controllers/posts_controller.index
    def handler_for(meth)
      # possibly not include _function
      underscored_name = @relative_path.sub(%r{app/(\w+)/},'').sub('.rb','')
      "handlers/#{process_type.pluralize}/#{underscored_name}.#{meth}"
    end

    # Example return: "handlers/controllers/posts.js"
    # TODO: rename this to dest_path or something better now since using native ruby
    def dest_path
      @relative_path
        .sub("app", "handlers")
    end
  end
end
