describe Jets::PolyFun::NodeExecutor do
  let(:fun) { Jets::PolyFun::NodeExecutor.new(task) }
  let(:task) { BooksController.all_public_tasks[:list] }

  context("python") do
    context("lets see the script") do
      let(:action) { :node }
      it "generates code" do
        code = fun.code
        expect(code).to include("var app = require")
      end
    end
  end
end
