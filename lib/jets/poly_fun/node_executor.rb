class Jets::PolyFun
  class NodeExecutor < BaseExecutor
    # Code for wrapper script that mimics lambda execution. Wrapper script usage:
    #
    #   node WRAPPER_SCRIPT EVENT
    #
    # Example:
    #
    #   node /tmp/jets/demo/executor/20180804-12816-imqb9/lambda_executor.js '{}'
    def lambda_executor_code
      meth = @task.meth
      code =<<-EOL
function callback(something, response) {
  var text = JSON.stringify(response)
  console.log(text)
}

var event = process.argv[2]
event = JSON.parse(event)
var context = {}

var app = require("./#{@task.meth}.js")
var resp = app.#{handler}(event, context, callback)
EOL
    end
  end
end
