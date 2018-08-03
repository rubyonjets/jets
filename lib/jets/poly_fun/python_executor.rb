class Jets::PolyFun
  class PythonExecutor
    def initialize(task)
      @task = task
    end

    def run(event, context)
      puts "python executor ran"
    end
  end
end