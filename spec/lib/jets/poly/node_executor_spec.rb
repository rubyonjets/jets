describe Jets::Poly::NodeExecutor do
  let(:fun) { Jets::Poly::NodeExecutor.new(task) }
  let(:task) { BooksController.all_public_definitions[:list] }

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
