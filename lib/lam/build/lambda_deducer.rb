class Lam::Build
  class LambdaDeducer
    attr_reader :handlers
    def initialize(path)
      @path = path
    end

    def run
      deduce
    end

    def class_name
      @path.sub(%r{app/(\w+)/},'').sub('.rb','').classify
    end

    def functions
      # Example: require "./app/controllers/posts_controller.rb"
      require_path = @path.starts_with?('/') ? @path : "#{Lam.root}#{@path}"
      require require_path

      class_name
      klass = class_name.constantize
      klass.lambda_functions
    end
  end
end
