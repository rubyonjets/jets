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
      klass_name = File.basename(@path, '.rb').classify
      klass = klass_name.constantize

      functions = klass.lambda_functions
      @handlers = functions.map { |fn| handler_data(klass_name, fn) }
    end

    # Transform the method to the
    def handler_data(klass_name, function_name)
      handler = compute_handler(klass_name, function_name)
      js_path = compute_js_path(klass_name, function_name)
      {
        handler: handler,
        js_path: js_path,
        js_method: function_name.to_s
      }
    end

    def compute_handler(klass_name, function_name)
      module_name = klass_name.sub(/Controller$/,'').underscore
      "handlers/controllers/#{module_name}.create"
    end

    def compute_js_path(klass_name, function_name)
      module_name = klass_name.sub(/Controller$/,'').underscore
      "handlers/controllers/#{module_name}.js"
    end
  end
end
