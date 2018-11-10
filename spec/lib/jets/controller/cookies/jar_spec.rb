describe Jets::Controller::Cookies::Jar do
  let(:jar) { Jets::Controller::Cookies::Jar.new(controller) }
  let(:controller) { PostsController.new(event, context, meth) }
  let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }
  let(:context) { nil }
  let(:meth) { "index" }

  context "cookies" do
    it "stores data" do
      cookies = jar
      cookies[:something] = 'foobar'
      expect(cookies[:something]).to eq 'foobar'

      cookies.merge! 'foo' => 'bar', 'bar' => 'baz'
      foo, bar = cookies.values_at 'foo', 'bar'
      expect(foo).to eq 'bar'
      expect(bar).to eq 'baz'

      expect(cookies.size).to eq 3
      # uncomment to debug
      # pp cookies.to_hash
      # pp controller.response.headers
    end
  end
end