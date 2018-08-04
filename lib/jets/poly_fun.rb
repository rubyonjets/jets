module Jets
  class PolyFun
    autoload :LambdaExecutor, 'jets/poly_fun/lambda_executor' # main class delegates to other classes
    autoload :PythonError, 'jets/poly_fun/python_error'
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
          backtrace = resp["stackTrace"] + caller
          backtrace = backtrace.map { |l| l.sub(/^\s+/,'') }
          raise PythonError.new(resp["errorMessage"], backtrace)
        end
        resp
      end
    end

    def task
      @app_class.tasks.find { |t| t.meth == @app_meth }
    end
    memoize :task
  end
end
