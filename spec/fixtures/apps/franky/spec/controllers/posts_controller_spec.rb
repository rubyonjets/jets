require 'spec_helper'

RSpec.describe PostsController, type: :controller do
  let(:context) { {} } # TODO: figure out a good context fixture

  it "index returns a success response" do
    event = payload("posts-index")
    controller = PostsController.new(event, context)
    response = controller.index
    # pp response
  end

  it "show returns a success response" do
    event = payload("posts-show")
    controller = PostsController.new(event, context)
    response = controller.show
    # pp response
  end
end
