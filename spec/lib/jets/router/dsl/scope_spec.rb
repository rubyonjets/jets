describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router scope" do
    it "single admin path" do
      output = draw do
        scope(path: :admin) do
          get "posts", to: "posts#index"
        end
      end
      text = <<~EOL
      posts GET /admin/posts posts#index
      EOL
    end

    it "nested admin path on multiple lines" do
      output = draw do
        scope(path: :v1) do
          scope(path: :admin) do
            get "posts", to: "posts#index"
          end
        end
      end
      text = <<~EOL
      posts GET /v1/admin/posts posts#index
      EOL
      expect(output).to eq(text)
    end

    it "nested admin path on oneline" do
      output = draw do
        scope(path: :v1) do
          scope(path: :admin) do
            get "posts", to: "posts#index"
          end
        end
      end
      text = <<~EOL
      posts GET /v1/admin/posts posts#index
      EOL
      expect(output).to eq(text)
    end

    it "nested admin path as string" do
      output = draw do
        scope "v1/admin" do
          get "posts", to: "posts#index"
        end
      end
      text = <<~EOL
      posts GET /v1/admin/posts posts#index
      EOL
      expect(output).to eq(text)
    end

    it "nested admin path as symbol" do
      output = draw do
        scope :admin do
          get "posts", to: "posts#index"
        end
      end
      text = <<~EOL
      posts GET /admin/posts posts#index
      EOL
      expect(output).to eq(text)
    end

    it "single admin as with individual routes" do
      output = draw do
        scope(as: :admin) do
          get "posts", to: "posts#index"
          get "posts/new", to: "posts#new"
          get "posts/:id", to: "posts#show"
          post "posts", to: "posts#create"
          get "posts/:id/edit", to: "posts#edit"
          put "posts/:id", to: "posts#update"
          post "posts/:id", to: "posts#update"
          patch "posts/:id", to: "posts#update"
          delete "posts/:id", to: "posts#delete"
        end
      end
      text = <<~EOL
      admin_posts     GET    /posts          posts#index
      new_admin_post  GET    /posts/new      posts#new
      admin_post      GET    /posts/:id      posts#show
      admin_posts     POST   /posts          posts#create
      edit_admin_post GET    /posts/:id/edit posts#edit
      admin_post      PUT    /posts/:id      posts#update
      admin_post      POST   /posts/:id      posts#update
      admin_post      PATCH  /posts/:id      posts#update
      admin_posts     DELETE /posts/:id      posts#delete
      EOL
      expect(output).to eq(text)
    end

    it "single admin as with resources" do
      output = draw do
        scope(as: :admin) do
          resources :posts
        end
      end
      text = <<~EOL
      admin_posts     GET    /posts          posts#index
      admin_posts     POST   /posts          posts#create
      new_admin_post  GET    /posts/new      posts#new
      edit_admin_post GET    /posts/:id/edit posts#edit
      admin_post      GET    /posts/:id      posts#show
      admin_post      PUT    /posts/:id      posts#update
      admin_post      PATCH  /posts/:id      posts#update
      admin_post      DELETE /posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)
    end

    # more general scope method
    it "admin module single method" do
      output = draw do
        scope(module: :admin) do
          get "posts", to: "posts#index"
        end
      end
      text = <<~EOL
      posts GET /posts admin/posts#index
      EOL
      expect(output).to eq(text)
    end

    it "admin module all methods" do
      output = draw do
        scope(module: :admin) do
          resources "posts"
        end
      end
      text = <<~EOL
      posts     GET    /posts          admin/posts#index
      posts     POST   /posts          admin/posts#create
      new_post  GET    /posts/new      admin/posts#new
      edit_post GET    /posts/:id/edit admin/posts#edit
      post      GET    /posts/:id      admin/posts#show
      post      PUT    /posts/:id      admin/posts#update
      post      PATCH  /posts/:id      admin/posts#update
      post      DELETE /posts/:id      admin/posts#destroy
      EOL

    end

    it "api/v1 module nested single method" do
      output = draw do
        scope(module: :api) do
          scope(module: :v1) do
            get "posts", to: "posts#index"
          end
        end
      end
      text = <<~EOL
      posts GET /posts api/v1/posts#index
      EOL
      expect(output).to eq(text)
    end

    it "api/v1 module nested all resources methods" do
      output = draw do
        scope(module: :api) do
          scope(module: :v1) do
            resources :posts
          end
        end
      end
      text = <<~EOL
      posts     GET    /posts          api/v1/posts#index
      posts     POST   /posts          api/v1/posts#create
      new_post  GET    /posts/new      api/v1/posts#new
      edit_post GET    /posts/:id/edit api/v1/posts#edit
      post      GET    /posts/:id      api/v1/posts#show
      post      PUT    /posts/:id      api/v1/posts#update
      post      PATCH  /posts/:id      api/v1/posts#update
      post      DELETE /posts/:id      api/v1/posts#destroy
      EOL
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")
    end

    it "api/v1 module oneline" do
      output = draw do
        scope(module: "api/v1") do
          get "posts", to: "posts#index"
        end
      end
      text = <<~EOL
      posts GET /posts api/v1/posts#index
      EOL
      expect(output).to eq(text)
    end
  end
end
