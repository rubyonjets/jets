describe Jets::PolyFun do
  let(:fun) { Jets::PolyFun.new(BooksController, action) }

  describe "successful python code" do
    let(:action) { :show }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "runs python code" do
      resp = fun.run(event)
      expect(resp["statusCode"]).to eq "200"
    end
  end

  describe "fail python code" do
    let(:action) { :error_test }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "runs python code" do
      expect { fun.run(event) }.to raise_error(Jets::PythonError)
    end
  end
end
