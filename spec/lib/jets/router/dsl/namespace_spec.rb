describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router namespace" do
    it "admin resources posts" do
      captured_scope = nil
      output = draw do
        namespace :admin do
          resources :posts
        end
      end
      text = <<~EOL
      admin_posts     GET    /admin/posts          admin/posts#index
      admin_posts     POST   /admin/posts          admin/posts#create
      new_admin_post  GET    /admin/posts/new      admin/posts#new
      edit_admin_post GET    /admin/posts/:id/edit admin/posts#edit
      admin_post      GET    /admin/posts/:id      admin/posts#show
      admin_post      PUT    /admin/posts/:id      admin/posts#update
      admin_post      PATCH  /admin/posts/:id      admin/posts#update
      admin_post      DELETE /admin/posts/:id      admin/posts#destroy
      EOL
      expect(output).to eq(text)

      expect(app.admin_posts_path).to eq("/admin/posts")
      expect(app.new_admin_post_path).to eq("/admin/posts/new")
      expect(app.admin_post_path(1)).to eq("/admin/posts/1")
      expect(app.edit_admin_post_path(1)).to eq("/admin/posts/1/edit")
    end

    it "namespace v1 namespace admin resources posts resources comments multiple lines" do
      output = draw do
        namespace :v1 do
          namespace :admin do
            resources :posts do
              resources :comments
            end
          end
        end
      end
      text = <<~EOL
      v1_admin_posts             GET    /v1/admin/posts                            v1/admin/posts#index
      v1_admin_posts             POST   /v1/admin/posts                            v1/admin/posts#create
      new_v1_admin_post          GET    /v1/admin/posts/new                        v1/admin/posts#new
      edit_v1_admin_post         GET    /v1/admin/posts/:id/edit                   v1/admin/posts#edit
      v1_admin_post              GET    /v1/admin/posts/:id                        v1/admin/posts#show
      v1_admin_post              PUT    /v1/admin/posts/:id                        v1/admin/posts#update
      v1_admin_post              PATCH  /v1/admin/posts/:id                        v1/admin/posts#update
      v1_admin_post              DELETE /v1/admin/posts/:id                        v1/admin/posts#destroy
      v1_admin_post_comments     GET    /v1/admin/posts/:post_id/comments          v1/admin/comments#index
      v1_admin_post_comments     POST   /v1/admin/posts/:post_id/comments          v1/admin/comments#create
      new_v1_admin_post_comment  GET    /v1/admin/posts/:post_id/comments/new      v1/admin/comments#new
      edit_v1_admin_post_comment GET    /v1/admin/posts/:post_id/comments/:id/edit v1/admin/comments#edit
      v1_admin_post_comment      GET    /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#show
      v1_admin_post_comment      PUT    /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#update
      v1_admin_post_comment      PATCH  /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#update
      v1_admin_post_comment      DELETE /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#destroy
      EOL
      expect(output).to eq(text)

      expect(app.v1_admin_posts_path).to eq("/v1/admin/posts")
      expect(app.new_v1_admin_post_path).to eq("/v1/admin/posts/new")
      expect(app.v1_admin_post_path(1)).to eq("/v1/admin/posts/1")
      expect(app.edit_v1_admin_post_path(1)).to eq("/v1/admin/posts/1/edit")

      expect(app.v1_admin_post_comments_path(1)).to eq("/v1/admin/posts/1/comments")
      expect(app.new_v1_admin_post_comment_path(1)).to eq("/v1/admin/posts/1/comments/new")
      expect(app.v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2")
      expect(app.edit_v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2/edit")
    end

    it "namespace v1/admin resources posts resources comments" do
      output = draw do
        namespace "v1/admin" do
          resources :posts do
            resources :comments
          end
        end
      end
      text = <<~EOL
      v1_admin_posts             GET    /v1/admin/posts                            v1/admin/posts#index
      v1_admin_posts             POST   /v1/admin/posts                            v1/admin/posts#create
      new_v1_admin_post          GET    /v1/admin/posts/new                        v1/admin/posts#new
      edit_v1_admin_post         GET    /v1/admin/posts/:id/edit                   v1/admin/posts#edit
      v1_admin_post              GET    /v1/admin/posts/:id                        v1/admin/posts#show
      v1_admin_post              PUT    /v1/admin/posts/:id                        v1/admin/posts#update
      v1_admin_post              PATCH  /v1/admin/posts/:id                        v1/admin/posts#update
      v1_admin_post              DELETE /v1/admin/posts/:id                        v1/admin/posts#destroy
      v1_admin_post_comments     GET    /v1/admin/posts/:post_id/comments          v1/admin/comments#index
      v1_admin_post_comments     POST   /v1/admin/posts/:post_id/comments          v1/admin/comments#create
      new_v1_admin_post_comment  GET    /v1/admin/posts/:post_id/comments/new      v1/admin/comments#new
      edit_v1_admin_post_comment GET    /v1/admin/posts/:post_id/comments/:id/edit v1/admin/comments#edit
      v1_admin_post_comment      GET    /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#show
      v1_admin_post_comment      PUT    /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#update
      v1_admin_post_comment      PATCH  /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#update
      v1_admin_post_comment      DELETE /v1/admin/posts/:post_id/comments/:id      v1/admin/comments#destroy
      EOL
      expect(output).to eq(text)

      expect(app.v1_admin_posts_path).to eq("/v1/admin/posts")
      expect(app.new_v1_admin_post_path).to eq("/v1/admin/posts/new")
      expect(app.v1_admin_post_path(1)).to eq("/v1/admin/posts/1")
      expect(app.edit_v1_admin_post_path(1)).to eq("/v1/admin/posts/1/edit")

      expect(app.v1_admin_post_comments_path(1)).to eq("/v1/admin/posts/1/comments")
      expect(app.new_v1_admin_post_comment_path(1)).to eq("/v1/admin/posts/1/comments/new")
      expect(app.v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2")
      expect(app.edit_v1_admin_post_comment_path(1,2)).to eq("/v1/admin/posts/1/comments/2/edit")
    end

    it "regular create route methods" do
      output = draw do
        namespace "admin" do
          get "posts", to: "posts#index"
          get "posts/:id", to: "posts#show"
        end
      end
      text = <<~EOL
      admin_posts GET /admin/posts     admin/posts#index
      admin_post  GET /admin/posts/:id admin/posts#show
      EOL
      expect(output).to eq(text)

      expect(app.admin_posts_path).to eq("/admin/posts")
      expect(app.admin_post_path(1)).to eq("/admin/posts/1")
    end

    # prettier namespace method
    it "api/v2 namespace" do
      output = draw do
        namespace "api/v2" do
          get "posts", to: "posts#index"
        end
      end
      route = route_set.routes.first
      expect(route.path).to eq "/api/v2/posts"
    end

    it "absolute controller path" do
      output = draw do
        namespace :admin do
          resources :posts, only: [:edit] do
            get :photo, on: :member, controller: "/photos"
          end
        end
      end
      text = <<~EOL
      edit_admin_post  GET /admin/posts/:id/edit  admin/posts#edit
      photo_admin_post GET /admin/posts/:id/photo photos#photo
      EOL
      expect(output).to eq(text)
    end
  end
end