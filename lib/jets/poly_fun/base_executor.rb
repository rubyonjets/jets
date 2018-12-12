require 'open3'
require 'tmpdir'

class Jets::PolyFun
  class BaseExecutor
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
      write(code)
      result = run_lambda_executor(event, context)
      cleanup
      result
    end

    def write(code)
      puts "lambda_executor_script #{lambda_executor_script}" if ENV['KEEP_LAMBDA_WRAPPER']
      IO.write(lambda_executor_script, code)
    end

    # Mimic Dir.mktmpdir randomness, not using Dir.mktmpdir because that generates
    # the folder at the /tmp level only.
    def create_tmpdir
      random = "#{Time.now.strftime("%Y%d%H")}-#{Process.pid}-#{SecureRandom.hex[0..6]}"
      tmpdir = "#{Jets.build_root}/executor/#{random}"
      FileUtils.mkdir_p(tmpdir)
      tmpdir
    end

    def copy_src_to_temp
      app_class = @task.class_name.constantize
      internal = app_class.respond_to?(:internal) && app_class.internal
      src = internal ?
        "#{File.expand_path("../internal", File.dirname(__FILE__))}/#{@task.poly_src_path}" :
        "#{Jets.root}#{@task.poly_src_path}"
      dest = "#{@temp_dir}/#{@task.poly_src_path}"

      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

    def lambda_executor_script
      File.dirname("#{@temp_dir}/#{@task.poly_src_path}") + "/lambda_executor" + @task.lang_ext
    end

    # When polymorphic method errors, this method reproduces an error in the lambda format
    # Here's some examples to help example:
    #
    # Example of what the raw python prints out to stderr:
    #
    #   Traceback (most recent call last):
    #     File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/lambda_executor.py", line 6, in <module>
    #       resp = handle(event, context)
    #     File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/index.py", line 22, in handle
    #       return response({'message': e.message}, 400)
    #     File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/index.py", line 5, in response
    #       badcode
    #   NameError: global name 'badcode' is not defined
    #
    # So last line has the error summary info.  Other lines have stack trace after the Traceback indicator.
    #
    # Example of the reproduced lambda error format:
    #
    #   {
    #     "errorMessage": "'NameError' object has no attribute 'message'",
    #     "errorType": "AttributeError",
    #     "stackTrace": [
    #       [
    #         "/var/task/handlers/controllers/posts_controller/python/index.py",
    #         22,
    #         "handle",
    #         "return response({'message': e.message}, 400)"
    #       ]
    #     ]
    #   }
    #
    def run_lambda_executor(event, context)
      interpreter = @task.lang
      command = %Q|#{interpreter} #{lambda_executor_script} '#{JSON.dump(event)}' '#{JSON.dump(context)}'|
      stdout, stderr, status = Open3.capture3(command)
      # puts "=> #{command}".colorize(:green)
      # puts "stdout #{stdout}"
      # puts "stderr #{stderr}"
      # puts "status #{status}"
      if status.success?
        stdout
      else
        # We'll mimic the way lambda displays an error.
        # $stderr.puts(stderr) # uncomment to debug
        error_lines = stderr.split("\n")
        error_message = error_lines.pop
        error_type = error_message.split(':').first
        error_lines.shift # remove first line that has the Traceback
        stack_trace = error_lines.reverse # python shows stack trace in opposite order from ruby
        JSON.dump(
          "errorMessage" => error_message,
          "errorType" => error_type, # hardcode
          "stackTrace" => stack_trace
        )
      end
    end

    def cleanup
      FileUtils.rm_rf(@temp_dir) unless ENV['KEEP_LAMBDA_WRAPPER']
    end

    def handler
      # Must use the generated CloudFormation template to get the handler because
      # the handler is derived from mutiple sources.
      resource = Jets::Resource::Lambda::Function.new(@task)
      full_handler = resource.properties["Handler"] # full handler here
      File.extname(full_handler).sub(/^./,'') # the extension of the full handler is the handler
    end
    memoize :handler
  end
end
