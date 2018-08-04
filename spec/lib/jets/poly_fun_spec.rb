describe Jets::PolyFun do
  let(:fun) { Jets::PolyFun.new(BooksController, action) }

  context("successful python command") do
    let(:action) { :show }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "produces lambda response payload" do
      resp = fun.run(event)
      expect(resp["statusCode"]).to eq "200"
    end
  end

  context("failed python command") do
    let(:action) { :error_test }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
    it "raises an custom PythonError exception" do
      expect { fun.run(event) }.to raise_error(Jets::PolyFun::PythonError)
    end
  end
end
