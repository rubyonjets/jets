describe Jets::PolyFun do
  let(:fun) { Jets::PolyFun.new(BooksController, :show) }

  describe "process" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/index.json") }
    it "processes python code" do
      puts fun.process(event)
    end
  end
end
