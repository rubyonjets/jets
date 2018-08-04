require 'open3'
require 'tmpdir'

class Jets::PolyFun
  class PythonExecutor
    extend Memoist

    def initialize(task)
      @task = task
    end

    # Handler is in properties:
    # 1. copy lambda function into tmp folder
    # 2. generate Lang wrapper script
    # 3. call wrapper script from ruby. Handle stdout and stderr and result. Pass info back to ruby
    def run(event, context)
      @temp_dir = create_tmpdir
      copy_src_to_temp
      generate_lambda_executor
      result = run_lambda_executor(event, context)
      cleanup
      result
    end

    def create_tmpdir
      build_dir = "#{Jets.build_root}/executor/"
      FileUtils.mkdir_p(build_dir)
      prefix = build_dir.sub('/tmp/','')
      Dir.mktmpdir(prefix)
    end

    def copy_src_to_temp
      # Must use FunctionProperties to get the handler because that the class that combines
      # the mutiple sources of how the handler can get set.
      # puts "handler path #{@task.handler_path}"

      src = "#{Jets.root}#{@task.poly_src_path}"
      filename = File.basename(@task.poly_src_path)
      dest = "#{@temp_dir}/#{filename}"
      FileUtils.cp(src, dest)
      # puts "dest #{dest}"
    end

    # Generates a wrapper script that mimics lambda execution. Wrapper script usage:
    #
    #   python WRAPPER_SCRIPT EVENT
    #
    # Example:
    #
    #   python /tmp/jets/demo/executor/20180804-12816-imqb9/lambda_executor.py '{}'
    def generate_lambda_executor
      meth = @task.meth
      code =<<-EOL
import sys
import json
from #{meth} import #{handler}
event = json.loads(sys.argv[1])
context = {}
resp = #{handler}(event, context)
result = json.dumps(resp)
print(result)
EOL
      IO.write(lambda_executor_script, code)
    end

    def run_lambda_executor(event, context)
      command = %Q|python #{lambda_executor_script} '#{JSON.dump(event)}' '#{JSON.dump(context)}'|
      stdout, stderr, status = Open3.capture3(command)
      # puts "=> #{command}".colorize(:green)
      # puts "stdout #{stdout}"
      # puts "stderr #{stderr}"
      # puts "status #{status}"
      if status
        stdout
      else
        $stderr.puts(stderr)
        {error: stderr}
        # TODO mimic lambda error response
      end
    end

    def cleanup
      # FileUtils.rm_rf(@temp_dir)
    end

    def lambda_executor_script
      "#{@temp_dir}/lambda_executor.py"
    end

    def handler
      builder_class = "Jets::Cfn::TemplateBuilders::FunctionProperties::#{@task.lang.to_s.classify}Builder".constantize
      builder = builder_class.new(@task)
      full_handler = builder.properties["Handler"] # full handler here
      File.extname(full_handler).sub(/^./,'') # the extension of the full handler is the handler
    end
    memoize :handler
  end
end