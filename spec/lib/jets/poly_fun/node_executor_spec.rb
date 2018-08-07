describe Jets::PolyFun::NodeExecutor do
  let(:fun) { Jets::PolyFun::NodeExecutor.new(task) }
  let(:task) { BooksController.all_tasks[:list] }

  context("python") do
    context("lets see the script") do
      let(:action) { :node }
      it "generates code" do
        code = fun.lambda_executor_code
        expect(code).to include("var app = require")
      end
    end
  end
end
