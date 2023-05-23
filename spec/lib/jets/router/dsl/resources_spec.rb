describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router resources" do
    it ":posts" do
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

      expect(app.posts_path).to eq("/posts")
    end

    it "only option posts comments" do
      output = draw do
        resources :posts, only: :new do
          resources :comments, only: [:edit]
        end
      end
      text = <<~EOL
      new_post          GET /posts/new                        posts#new
      edit_post_comment GET /posts/:post_id/comments/:id/edit comments#edit
      EOL
      expect(output).to eq(text)
      expect(route_set.routes).to be_a(Array)
      expect(route_set.routes.first).to be_a(Jets::Router::Route)
    end

    it "nested with another resources posts comments" do
      output = draw do
        resources :posts do
          resources :comments
        end
      end
      text = <<~EOL
      posts             GET    /posts                            posts#index
      posts             POST   /posts                            posts#create
      new_post          GET    /posts/new                        posts#new
      edit_post         GET    /posts/:id/edit                   posts#edit
      post              GET    /posts/:id                        posts#show
      post              PUT    /posts/:id                        posts#update
      post              PATCH  /posts/:id                        posts#update
      post              DELETE /posts/:id                        posts#destroy
      post_comments     GET    /posts/:post_id/comments          comments#index
      post_comments     POST   /posts/:post_id/comments          comments#create
      new_post_comment  GET    /posts/:post_id/comments/new      comments#new
      edit_post_comment GET    /posts/:post_id/comments/:id/edit comments#edit
      post_comment      GET    /posts/:post_id/comments/:id      comments#show
      post_comment      PUT    /posts/:post_id/comments/:id      comments#update
      post_comment      PATCH  /posts/:post_id/comments/:id      comments#update
      post_comment      DELETE /posts/:post_id/comments/:id      comments#destroy
      EOL
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")

      expect(app.post_comments_path(1)).to eq("/posts/1/comments")
      expect(app.new_post_comment_path(1)).to eq("/posts/1/comments/new")
      expect(app.post_comment_path(1, 2)).to eq("/posts/1/comments/2")
      expect(app.edit_post_comment_path(1, 2)).to eq("/posts/1/comments/2/edit")
    end

    it "member and collection" do
      output = draw do
        resources :accounts, only: [] do
          get :photo, on: :member
          get :comments, on: :collection
        end
      end
      text = <<~EOL
      photo_account     GET /accounts/:id/photo accounts#photo
      comments_accounts GET /accounts/comments  accounts#comments
      EOL
      expect(output).to eq(text)

      expect(app.photo_account_path(1)).to eq("/accounts/1/photo")
      expect(app.comments_accounts_path).to eq("/accounts/comments")
    end

    it "as articles" do
      output = draw do
        resources :posts, as: "articles"
      end
      text = <<~EOL
      articles     GET    /posts          posts#index
      articles     POST   /posts          posts#create
      new_article  GET    /posts/new      posts#new
      edit_article GET    /posts/:id/edit posts#edit
      article      GET    /posts/:id      posts#show
      article      PUT    /posts/:id      posts#update
      article      PATCH  /posts/:id      posts#update
      article      DELETE /posts/:id      posts#destroy
      EOL
      expect(output).to eq(text)

      expect(app.articles_path).to eq("/posts")
      expect(app.new_article_path).to eq("/posts/new")
      expect(app.article_path(1)).to eq("/posts/1")
      expect(app.edit_article_path(1)).to eq("/posts/1/edit")
    end

    it "module admin" do
      output = draw do
        resources :posts, module: "admin"
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
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")
    end

    it "path admin" do
      output = draw do
        resources :posts, path: "admin/posts"
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

    it "prefix with nested resources comments" do
      output = draw do
        resources :posts, path: "admin/posts" do
          resources :comments
        end
      end
      text = <<~EOL
      posts             GET    /admin/posts                            posts#index
      posts             POST   /admin/posts                            posts#create
      new_post          GET    /admin/posts/new                        posts#new
      edit_post         GET    /admin/posts/:id/edit                   posts#edit
      post              GET    /admin/posts/:id                        posts#show
      post              PUT    /admin/posts/:id                        posts#update
      post              PATCH  /admin/posts/:id                        posts#update
      post              DELETE /admin/posts/:id                        posts#destroy
      post_comments     GET    /admin/posts/:post_id/comments          comments#index
      post_comments     POST   /admin/posts/:post_id/comments          comments#create
      new_post_comment  GET    /admin/posts/:post_id/comments/new      comments#new
      edit_post_comment GET    /admin/posts/:post_id/comments/:id/edit comments#edit
      post_comment      GET    /admin/posts/:post_id/comments/:id      comments#show
      post_comment      PUT    /admin/posts/:post_id/comments/:id      comments#update
      post_comment      PATCH  /admin/posts/:post_id/comments/:id      comments#update
      post_comment      DELETE /admin/posts/:post_id/comments/:id      comments#destroy
      EOL

      expect(output).to eq(text)

      expect(app.posts_path).to eq("/admin/posts")
      expect(app.new_post_path).to eq("/admin/posts/new")
      expect(app.post_path(1)).to eq("/admin/posts/1")
      expect(app.edit_post_path(1)).to eq("/admin/posts/1/edit")

      expect(app.post_comments_path(1)).to eq("/admin/posts/1/comments")
      expect(app.new_post_comment_path(1)).to eq("/admin/posts/1/comments/new")
      expect(app.post_comment_path(1, 2)).to eq("/admin/posts/1/comments/2")
      expect(app.edit_post_comment_path(1, 2)).to eq("/admin/posts/1/comments/2/edit")
    end

    it "controller articles" do
      output = draw do
        resources :posts, controller: "articles"
      end
      text = <<~EOL
      posts     GET    /posts          articles#index
      posts     POST   /posts          articles#create
      new_post  GET    /posts/new      articles#new
      edit_post GET    /posts/:id/edit articles#edit
      post      GET    /posts/:id      articles#show
      post      PUT    /posts/:id      articles#update
      post      PATCH  /posts/:id      articles#update
      post      DELETE /posts/:id      articles#destroy
      EOL

      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")
    end

    it "controller with namespace admin/posts" do
      output = draw do
        resources :posts, controller: "admin/posts"
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
      expect(output).to eq(text)

      expect(app.posts_path).to eq("/posts")
      expect(app.new_post_path).to eq("/posts/new")
      expect(app.post_path(1)).to eq("/posts/1")
      expect(app.edit_post_path(1)).to eq("/posts/1/edit")
    end

    it "param custom my_comment_id" do
      output = draw do
        resources :posts do
          resources :comments, param: :my_comment_id
        end
        resources :users, param: :my_user_id
      end
      text = <<~EOL
      posts             GET    /posts                                       posts#index
      posts             POST   /posts                                       posts#create
      new_post          GET    /posts/new                                   posts#new
      edit_post         GET    /posts/:id/edit                              posts#edit
      post              GET    /posts/:id                                   posts#show
      post              PUT    /posts/:id                                   posts#update
      post              PATCH  /posts/:id                                   posts#update
      post              DELETE /posts/:id                                   posts#destroy
      post_comments     GET    /posts/:post_id/comments                     comments#index
      post_comments     POST   /posts/:post_id/comments                     comments#create
      new_post_comment  GET    /posts/:post_id/comments/new                 comments#new
      edit_post_comment GET    /posts/:post_id/comments/:my_comment_id/edit comments#edit
      post_comment      GET    /posts/:post_id/comments/:my_comment_id      comments#show
      post_comment      PUT    /posts/:post_id/comments/:my_comment_id      comments#update
      post_comment      PATCH  /posts/:post_id/comments/:my_comment_id      comments#update
      post_comment      DELETE /posts/:post_id/comments/:my_comment_id      comments#destroy
      users             GET    /users                                       users#index
      users             POST   /users                                       users#create
      new_user          GET    /users/new                                   users#new
      edit_user         GET    /users/:my_user_id/edit                      users#edit
      user              GET    /users/:my_user_id                           users#show
      user              PUT    /users/:my_user_id                           users#update
      user              PATCH  /users/:my_user_id                           users#update
      user              DELETE /users/:my_user_id                           users#destroy
      EOL
      expect(output).to eq(text)

      expect(app.users_path).to eq("/users")
      expect(app.new_user_path).to eq("/users/new")
      expect(app.user_path(1)).to eq("/users/1")
      expect(app.edit_user_path(1)).to eq("/users/1/edit")
    end

    it "param custom my_comment_id with block" do
      output = draw do
        resources :posts do
          resources :comments, param: :my_comment_id, only: [:create] do
            get :test, on: :member
          end
        end

        resources :cars, param: :my_parent_id do
          resources :ratings, only: [:create, :show], param: :my_child_id do
            # nothing
          end
        end

        resources :users, param: :my_user_id, only: [] do
          get :test, on: :member
        end
      end
      text = <<~EOL
      posts             GET    /posts                                       posts#index
      posts             POST   /posts                                       posts#create
      new_post          GET    /posts/new                                   posts#new
      edit_post         GET    /posts/:id/edit                              posts#edit
      post              GET    /posts/:id                                   posts#show
      post              PUT    /posts/:id                                   posts#update
      post              PATCH  /posts/:id                                   posts#update
      post              DELETE /posts/:id                                   posts#destroy
      post_comments     POST   /posts/:post_id/comments                     comments#create
      test_post_comment GET    /posts/:post_id/comments/:my_comment_id/test comments#test
      cars              GET    /cars                                        cars#index
      cars              POST   /cars                                        cars#create
      new_car           GET    /cars/new                                    cars#new
      edit_car          GET    /cars/:my_parent_id/edit                     cars#edit
      car               GET    /cars/:my_parent_id                          cars#show
      car               PUT    /cars/:my_parent_id                          cars#update
      car               PATCH  /cars/:my_parent_id                          cars#update
      car               DELETE /cars/:my_parent_id                          cars#destroy
      car_ratings       POST   /cars/:my_parent_id/ratings                  ratings#create
      car_rating        GET    /cars/:my_parent_id/ratings/:my_child_id     ratings#show
      test_user         GET    /users/:my_user_id/test                      users#test
      EOL
      expect(output).to eq(text)
    end
  end
end
