class Jets::PolyFun
  class LambdaExecutor
    def initialize(task)
      @task = task
    end

    def run(event, context)
      executor_class = "#{task.lang}_executor".classify.constantize
      executor = executor_class.new(task)
      executor.run(event, context)
    end
  end
end