# Example:
# describe PostsController, type: :controller do
#   it "index returns a success response" do
#     get '/posts'
#     expect(response.status).to eq 200
#     pp response.body
#   end
#
#   it "show returns a success response" do
#     Post.create(id: 1) unless Post.find_by(id: 1) # TODO: set up factory_bot
#     get '/posts/:id', id: 1
#     expect(response.status).to eq 200
#     pp response.body
#   end
# end
