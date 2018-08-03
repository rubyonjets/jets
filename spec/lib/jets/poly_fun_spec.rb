describe Jets::PolyFun do
  let(:fun) { Jets::PolyFun.new() }
  let(:app_class) { BooksController }
  let(:app_meth) { :show }

  describe "process" do
    let(:event) { { json_file("spec/fixtures/dumps/rack/books/index.json") } }
    it "processes python code" do
      puts fun.process(event)
    end
  end
end
