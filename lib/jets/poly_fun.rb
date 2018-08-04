module Jets
  class PythonError < StandardError
    def initialize(message, backtrace)
      super(message)
      set_backtrace(backtrace)
    end
  end

  class PolyFun
    autoload :LambdaExecutor, 'jets/poly_fun/lambda_executor' # main class delegates to other classes
    autoload :PythonExecutor, 'jets/poly_fun/python_executor' # main class delegates to other classes
    autoload :NodeExecutor, 'jets/poly_fun/node_executor' # main class delegates to other classes

    extend Memoist

    def initialize(app_class, app_meth)
      @app_class = app_class # already a Constant, IE: PostController
      @app_meth = app_meth.to_sym
    end

    def run(event, context={})
      if task.lang == :ruby
        # controller = PostsController.new(event, content)
        # resp = controller.edit
        @app_class.process(event, context, @app_meth)
      else
        executor = LambdaExecutor.new(task)
        resp = executor.run(event, context)
        if resp["errorMessage"]
          # puts resp["errorMessage"]
          # puts resp["stackTrace"]
          puts "here1"
          raise PythonError.new(resp["errorMessage"], resp["stackTrace"])
          puts "here2"
          # raise
          # raise
        end
      end
    end

    def task
      @app_class.tasks.find { |t| t.meth == @app_meth }
    end
    memoize :task
  end
end
