describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router path" do
    it "admin resources posts" do
      output = draw do
        path :admin do
          resources :posts
        end
      end
      text = <<~EOL
      posts     GET    /admin/posts          posts#index
      posts     POST   /admin/posts          posts#create
      new_post  GET    /admin/posts/new      posts#new
      edit_post GET    /admin/posts/:id/edit posts#edit
      post      GET    /admin/posts/:id      posts#show
      post      PUT    /admin/posts/:id      posts#update
      post      PATCH  /admin/posts/:id      posts#update
      post      DELETE /admin/posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/admin/posts")
      expect(app.new_post_path).to eq("/admin/posts/new")
      expect(app.post_path(1)).to eq("/admin/posts/1")
      expect(app.edit_post_path(1)).to eq("/admin/posts/1/edit")
    end
  end
end
