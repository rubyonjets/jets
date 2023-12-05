describe Jets::Router do
  let(:route_set)  { Jets::Router::RouteSet.new }
  let(:app)     { RouterTestApp.new }

  describe "Router no scope" do
    it "get posts resources" do
      output = draw do
        resources :posts
      end
      text = <<~EOL
      posts     GET    /posts          posts#index
      posts     POST   /posts          posts#create
      new_post  GET    /posts/new      posts#new
      edit_post GET    /posts/:id/edit posts#edit
      post      GET    /posts/:id      posts#show
      post      PUT    /posts/:id      posts#update
      post      PATCH  /posts/:id      posts#update
      post      DELETE /posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)
    end

    it "get posts create_route methods" do
      output = draw do
        get "posts", to: "posts#index"
        post "posts", to: "posts#create"
        get "posts/new", to: "posts#new"
        get "posts/:id/edit", to: "posts#edit"
        get "posts/:id", to: "posts#show"
        put "posts/:id", to: "posts#update"
        patch "posts/:id", to: "posts#update"
        delete "posts/:id", to: "posts#destroy"
      end
      text = <<~EOL
      posts     GET    /posts          posts#index
      posts     POST   /posts          posts#create
      new_post  GET    /posts/new      posts#new
      edit_post GET    /posts/:id/edit posts#edit
      post      GET    /posts/:id      posts#show
      post      PUT    /posts/:id      posts#update
      post      PATCH  /posts/:id      posts#update
      post      DELETE /posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")
    end

    it "any with get" do
      output = draw do
        any "comments/hot", to: "comments#hot"
        get "landing/foo/bar", to: "posts#index"
        get "admin/pages", to: "admin/pages#index"
        get "related_posts/:id", to: "related_posts#show"
        any "others/*proxy", to: "others#catchall"
      end
      # Named routes helpers are not generated with any
      text = <<~EOL
                      ANY /comments/hot      comments#hot
      landing_foo_bar GET /landing/foo/bar   posts#index
      admin_pages     GET /admin/pages       admin/pages#index
      related_post    GET /related_posts/:id related_posts#show
                      ANY /others/*proxy     others#catchall
      EOL
      expect(output).to eq(text)
    end

    it "resources and no scope together" do
      output = draw do
        resources :articles
        resources :posts
        any "comments/hot", to: "comments#hot"
        get "landing/posts", to: "posts#index"
        get "admin/pages", to: "admin/pages#index"
        get "related_posts/:id", to: "related_posts#show"
        any "others/*proxy", to: "others#catchall"
      end
      text = <<~EOL
      articles      GET    /articles          articles#index
      articles      POST   /articles          articles#create
      new_article   GET    /articles/new      articles#new
      edit_article  GET    /articles/:id/edit articles#edit
      article       GET    /articles/:id      articles#show
      article       PUT    /articles/:id      articles#update
      article       PATCH  /articles/:id      articles#update
      article       DELETE /articles/:id      articles#destroy
      posts         GET    /posts             posts#index
      posts         POST   /posts             posts#create
      new_post      GET    /posts/new         posts#new
      edit_post     GET    /posts/:id/edit    posts#edit
      post          GET    /posts/:id         posts#show
      post          PUT    /posts/:id         posts#update
      post          PATCH  /posts/:id         posts#update
      post          DELETE /posts/:id         posts#destroy
                    ANY    /comments/hot      comments#hot
      landing_posts GET    /landing/posts     posts#index
      admin_pages   GET    /admin/pages       admin/pages#index
      related_post  GET    /related_posts/:id related_posts#show
                    ANY    /others/*proxy     others#catchall
      EOL
      expect(output).to eq(text)
    end

    it "root" do
      output = draw do
        root "posts#index"
      end
      text = <<~EOL
      root GET / posts#index
      EOL
      expect(output).to eq(text)

      route = route_set.routes.first
      expect(route).to be_a(Jets::Router::Route)
      expect(route.homepage?).to be true
      expect(route.to).to eq "posts#index"
      expect(route.path).to eq '/'
      expect(route.http_method).to eq "GET"
    end

    it "path as option" do
      output = draw do
        get path: "posts", to: "posts#index", path: "posts"
      end
      text = <<~EOL
      posts GET /posts posts#index
      EOL
      expect(output).to eq(text)
    end
  end
end
