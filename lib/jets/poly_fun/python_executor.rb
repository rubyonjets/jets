require 'open3'

class Jets::PolyFun
  class PythonExecutor
    def initialize(task)
      @task = task
    end

    # Handler is in properties:
    # 1. copy lambda function into tmp folder
    # 2. generate Lang wrapper script
    # 3. call wrapper script from ruby. Handle stdout and stderr and result. Pass info back to ruby
    def run(event, context)
      puts "python executor ran"
      copy_to_temp
      generate_wrapper
      execute_wrapper
    end

    def copy_to_temp
      builder_class = "Jets::Cfn::TemplateBuilders::FunctionProperties::#{@task.lang.to_s.classify}Builder".constantize
      builder = builder_class.new(@task)
      full_handler = builder.properties["Handler"] # full handler here
      puts "full_handler #{full_handler.inspect}"
      puts "handler path #{@task.handler_path}"

      # src = task. # TODO: need to get the full handler??
      # dest = "#{Jets.build_root}/executor/#{filename}"
      # FileUtils.mkdir_p(File.dirname(dest))
      # FileUtils.cp(src, dest)
    end

    def generate_wrapper
      # ... code below
    end

    def execute_wrapper
      return
      stdout, stderr, status =Open3.capture3(lambda_executor_wrapper)
      if status
        stdout
      else
        $stderr.puts(stderr)
        {error: stderr}
        # TODO mimic lambda error response
      end
    end
  end
end