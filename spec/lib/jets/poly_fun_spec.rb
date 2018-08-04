describe Jets::PolyFun do
  let(:fun) { Jets::PolyFun.new(BooksController, :show) }

  describe "run" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "runs python code" do
      result = fun.run(event)
      data = JSON.load(result)
      expect(data["statusCode"]).to eq "200"
    end
  end
end
