describe Jets::Resource::ApiGateway::RestApi::Routes::Change::Base do
  let(:base) do
    Jets::Resource::ApiGateway::RestApi::Routes::Change::Base.new
  end
  let(:lambda) do
    lambda = double(:lambda).as_null_object
    lambda
  end

  it "recreate_path" do
    path = base.recreate_path('/posts/{id}/edit')
    expect(path).to eq 'posts/:id/edit'
  end

  it "recreate_to" do
    method_uri = "arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:112233445566:function:demo-test-posts_controller-show/invocations"
    allow(base).to receive(:lambda_function_description).and_return("PostsController#show")
    to = base.recreate_to(method_uri)
    expect(to).to eq 'posts#show'
  end
end
