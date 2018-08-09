module Jets
  class PolyFun
    autoload :LambdaExecutor, 'jets/poly_fun/lambda_executor' # main class delegates to other classes

    autoload :BaseExecutor, 'jets/poly_fun/base_executor'
    autoload :PythonExecutor, 'jets/poly_fun/python_executor'
    autoload :NodeExecutor, 'jets/poly_fun/node_executor'

    autoload :PythonError, 'jets/poly_fun/python_error'
    autoload :NodeError, 'jets/poly_fun/node_error'

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
          raise_error(resp)
        end
        resp
      end
    end

    def raise_error(resp)
      backtrace = resp["stackTrace"] + caller
      backtrace = backtrace.map { |l| l.sub(/^\s+/,'') }
      # Adjust the paths from the tmp path to the app path to improve user debugging
      # experience. Example:
      # From:
      #   File "/tmp/jets/lite/executor/20180917-16777-43a9e48/app/controllers/jets/public_controller/python/show.py", line 32
      # To:
      #   File "app/controllers/jets/public_controller/python/show.py", line 32      backtrace =
      backtrace = backtrace.map do |l|
        if l.include?(Jets.build_root) && !l.include?("lambda_executor.")
          l.sub(/\/tmp\/jets.*executor\/\d{8}-+.*?\//, '')
        else
          l
        end
      end

      # IE: Jets::PolyFun::PythonError
      error_class = "Jets::PolyFun::#{task.lang.to_s.classify}Error".constantize
      raise error_class.new(resp["errorMessage"], backtrace)
    end

    def task
      @app_class.all_tasks[@app_meth]
    end
    memoize :task
  end
end
