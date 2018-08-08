require 'json'

class Jets::PolyFun
  class LambdaExecutor
    def initialize(task)
      @task = task
    end

    def run(event, context)
      executor_class = "Jets::PolyFun::#{@task.lang.capitalize}Executor".constantize
      executor = executor_class.new(@task)
      text = executor.run(event, context)
      JSON.load(text)
    end
  end
end