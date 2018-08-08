class Jets::PolyFun
  class PythonExecutor < BaseExecutor
    # Code for wrapper script that mimics lambda execution. Wrapper script usage:
    #
    #   python WRAPPER_SCRIPT EVENT
    #
    # Example:
    #
    #   python /tmp/jets/demo/executor/20180804-12816-imqb9/lambda_executor.py '{}'
    def code
      <<-EOL
import sys
import json
from #{@task.meth} import #{handler}
event = json.loads(sys.argv[1])
context = {}
resp = #{handler}(event, context)
result = json.dumps(resp)
print(result)
EOL
    end
  end
end