class Jets::PolyFun
  class NodeExecutor < BaseExecutor
    # Code for wrapper script that mimics lambda execution. Wrapper script usage:
    #
    #   node WRAPPER_SCRIPT EVENT
    #
    # Example:
    #
    #   node /tmp/jets/demo/executor/20180804-12816-imqb9/lambda_executor.js '{}'
    #
    def code
      if async_syntax?
        async_code
      else
        callback_code
      end
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-handler.html
    def async_syntax?
      app_path = Jets.root + @task.handler_path.sub('handlers/', 'app/')
      source_code = IO.read(app_path)
      source_code.match(/=\s*async.*\(/)
    end

    def async_code
      <<-EOL
var event = process.argv[2]
event = JSON.parse(event)
var context = {}

var app = require("./#{@task.meth}.js")
app.#{handler}(event, context).then(resp => console.log(JSON.stringify(resp)))
EOL
    end


    def callback_code
      <<-EOL
function callback(error, response) {
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
