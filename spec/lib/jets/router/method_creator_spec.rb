class MethodCreaterView
  include Jets::Router::Helpers::NamedRoutesHelper
end

describe Jets::Router::MethodCreator do
  let(:creator) { Jets::Router::MethodCreator.new(options, scope) }
  let(:view)    { MethodCreaterView.new }
  let(:scope)   { Jets::Router::Scope.new }
  before(:each) { Jets::Router::Helpers::NamedRoutesHelper.clear! }

  context "top-level" do
    context "posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.posts_path).to eq "/posts"
      end
    end

    context "new_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.new_post_path).to eq "/posts/new"
      end
    end

    context "post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.edit_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  # scope module: "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "scope module" do
    context "posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.posts_path).to eq "/posts"
      end
    end

    context "new_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.new_post_path).to eq "/posts/new"
      end
    end

    context "post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.edit_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  # scope as: "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "scope as" do
    context "api_v1_posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, as: "api_v1_posts" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.api_v1_posts_path).to eq "/posts"
      end
    end

    context "new_api_v1_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, as: "new_api_v1_post" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.new_api_v1_post_path).to eq "/posts/new"
      end
    end

    context "api_v1_post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, as: "api_v1_post" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.api_v1_post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_api_v1_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, as: "edit_api_v1_post" }
      end
      it "method" do
        creator.define_url_helper!
        expect(view.edit_api_v1_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  context "url with dash" do
    let(:options) do
      { to: "posts#index", path: "url-with-dash", method: :get, as: :url_with_dash }
    end
    it "method" do
      creator.define_url_helper!
      expect(view.url_with_dash_path).to eq "/url-with-dash"
    end
  end

  context "resources" do
    # The scope is below is created from the routes below:
    #
    #     resources :posts, only: [] do
    #       resources :comments, only: :show
    #     end
    #
    # It's pretty tedious to spec named routes helper methods like this so they are tested by
    # building a entire route itself in router_spec.rb.
    #
    # This spec is helpful to see the internal structure.
    #
    let(:scope) do
      s1 = Jets::Router::Scope.new
      s2 = Jets::Router::Scope.new({:as=>:posts, :prefix=>:posts, :from=>:resources}, s1, 2)
      s3 = Jets::Router::Scope.new({:as=>:comments, :prefix=>:comments, :from=>:resources}, s2, 3)
      s3
    end
    let(:options) do
      { to: "comments#show", path: "comments/:id", method: :get, from_scope: true}
    end

    it "method" do
      creator.define_url_helper!
      puts Jets::Router::Helpers::NamedRoutesHelper.public_instance_methods(false)
      expect(view.post_comment_path(1, 2)).to eq "/posts/1/comments/2"
    end
  end
end
