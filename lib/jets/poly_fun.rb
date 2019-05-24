module Jets
  class PolyFun
    extend Memoist

    def initialize(app_class, app_meth)
      @app_class = app_class # already a Constant, IE: PostController
      @app_meth = app_meth.to_sym
    end

    def run(event, context={})
      check_private_method!

      if task.lang == :ruby
        # controller = PostsController.new(event, content)
        # resp = controller.edit
        run_ruby_code(event, context)
      else
        executor = LambdaExecutor.new(task)
        resp = executor.run(event, context)
        if resp["errorMessage"]
          raise_error(resp)
        end
        resp
      end
    end

    def run_ruby_code(event, context)
      @app_class.process(event, context, @app_meth)
    rescue Exception => e
      Jets.on_exception(e)
      raise(e)
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
      error_class = "Jets::PolyFun::#{task.lang.to_s.camelize}Error".constantize
      raise error_class.new(resp["errorMessage"], backtrace)
    end

    def task
      task = @app_class.all_public_tasks[@app_meth]
      # Provider user a better error message to user than a nil failure.
      unless task
        raise "Unable to find #{@app_class}##{@app_meth}"
      end
      task
    end
    memoize :task

    def check_private_method!
      private_detected = @app_class.all_private_tasks.keys.include?(@app_meth)
      return unless private_detected # Ok to continue

      raise "The #{@app_class}##{@app_meth} is a private method.  Unable to call it unless it is public"
    end
  end
end
