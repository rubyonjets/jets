class Lam::Build
  class LambdaDeducer
    attr_reader :handlers
    def initialize(path)
      @path = path
    end

    def run
      deduce
    end

    def deduce
      # Example: require "app/controllers/posts_controller.rb"
      require "#{ENV['PROJECT_ROOT']}/#{@path}"
      # Example: @klass_name = "PostsController"
      @klass_name = File.basename(@path, '.rb').classify
      klass = @klass_name.constantize
      @handlers = klass.lambda_functions.map { |fn| handler_info(fn) }
    end

    # Transform the method to the handler info
    def handler_info(function_name)
      handler = get_handler(function_name)
      js_path = get_js_path(function_name)
      {
        handler: handler,
        js_path: js_path,
        js_method: function_name.to_s
      }
    end

    def get_handler(function_name)
      "handlers/controllers/#{module_name}.create"
    end

    def get_js_path(function_name)
      "handlers/controllers/#{module_name}.js"
    end

    def module_name
      @klass_name.sub(/Controller$/,'').underscore
    end
  end
end
