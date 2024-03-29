describe Jets::Poly do
  let(:fun) { Jets::Poly.new(BooksController, action) }

  context("python") do
    context("successful command") do
      let(:action) { :show }
      let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
      it "produces lambda response payload" do
        resp = fun.run(event)
        expect(resp["statusCode"]).to eq "200"
      end
    end

    context("failed command") do
      let(:action) { :error_test }
      let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/show.json") }
      it "raises an custom PythonError exception" do
        expect { fun.run(event) }.to raise_error(Jets::Poly::PythonError)
      end
    end
  end

  context("node callback syntax") do
    context("successful command") do
      let(:action) { :list }
      let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/list.json") }
      it "produces lambda response payload" do
        resp = fun.run(event)
        expect(resp["statusCode"]).to eq "200"
      end
    end

    context("failed command") do
      let(:action) { :node_error_test }
      let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/list.json") }
      it "raises an custom NodeError exception" do
        expect { fun.run(event) }.to raise_error(Jets::Poly::NodeError)
      end
    end
  end

  # Note the specs work with node v8.10.0
  context("node async syntax") do
    context("successful command") do
      let(:action) { :node_async }
      # event doesnt really matter
      let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/list.json") }
      it "produces lambda response payload" do
        resp = fun.run(event)
        expect(resp["statusCode"]).to eq "200"
      end
    end
  end
end
