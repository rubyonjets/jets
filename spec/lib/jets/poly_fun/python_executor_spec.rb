describe Jets::PolyFun::PythonExecutor do
  let(:executor) { Jets::PolyFun::PythonExecutor.new(task) }
  let(:task) { double(:null).as_null_object }

  context("failed python command") do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "produces lambda format error response" do
      stdout = ""
      stderr = stderr_data
      status = double(:null).as_null_object
      allow(status).to receive(:success?).and_return(false)
      allow(Open3).to receive(:capture3).and_return([stdout, stderr, status])

      text = executor.run_lambda_executor(event, {})
      expect(text).to include("stackTrace")
    end


    def stderr_data
      <<-EOL
  Traceback (most recent call last):
    File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/lambda_executor.py", line 6, in <module>
      resp = handle(event, context)
    File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/index.py", line 22, in handle
      return response({'message': e.message}, 400)
    File "/tmp/jets/lite/executor/20180804-10727-mcs6qk/index.py", line 5, in response
      badcode
  NameError: global name 'badcode' is not defined
      EOL
    end
  end
end
