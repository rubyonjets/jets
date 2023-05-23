describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router nested resources" do
    it "plural to plural" do
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
      expect(app.post_comment_path(1,2)).to eq("/posts/1/comments/2")
      expect(app.edit_post_comment_path(1,2)).to eq("/posts/1/comments/2/edit")
    end

    it "singular to plural" do
      output = draw do
        resource :account do
          resources :api_keys
        end
      end
      text = <<~EOL
      account              POST   /account                   accounts#create
      new_account          GET    /account/new               accounts#new
      edit_account         GET    /account/edit              accounts#edit
      account              GET    /account                   accounts#show
      account              PUT    /account                   accounts#update
      account              PATCH  /account                   accounts#update
      account              DELETE /account                   accounts#destroy
      account_api_keys     GET    /account/api_keys          api_keys#index
      account_api_keys     POST   /account/api_keys          api_keys#create
      new_account_api_key  GET    /account/api_keys/new      api_keys#new
      edit_account_api_key GET    /account/api_keys/:id/edit api_keys#edit
      account_api_key      GET    /account/api_keys/:id      api_keys#show
      account_api_key      PUT    /account/api_keys/:id      api_keys#update
      account_api_key      PATCH  /account/api_keys/:id      api_keys#update
      account_api_key      DELETE /account/api_keys/:id      api_keys#destroy
      EOL
      expect(output).to eq(text)

      expect(app.new_account_path).to eq("/account/new")
      expect(app.account_path).to eq("/account")
      expect(app.edit_account_path).to eq("/account/edit")

      expect(app.account_api_keys_path).to eq("/account/api_keys")
      expect(app.new_account_api_key_path).to eq("/account/api_keys/new")
      expect(app.account_api_key_path(1)).to eq("/account/api_keys/1")
      expect(app.edit_account_api_key_path(1)).to eq("/account/api_keys/1/edit")
    end

    it "plural to singular" do
      output = draw do
        resources :books do
          resource :cover
        end
      end
      text = <<~EOL
      books           GET    /books                     books#index
      books           POST   /books                     books#create
      new_book        GET    /books/new                 books#new
      edit_book       GET    /books/:id/edit            books#edit
      book            GET    /books/:id                 books#show
      book            PUT    /books/:id                 books#update
      book            PATCH  /books/:id                 books#update
      book            DELETE /books/:id                 books#destroy
      book_cover      POST   /books/:book_id/cover      covers#create
      new_book_cover  GET    /books/:book_id/cover/new  covers#new
      edit_book_cover GET    /books/:book_id/cover/edit covers#edit
      book_cover      GET    /books/:book_id/cover      covers#show
      book_cover      PUT    /books/:book_id/cover      covers#update
      book_cover      PATCH  /books/:book_id/cover      covers#update
      book_cover      DELETE /books/:book_id/cover      covers#destroy
      EOL
      expect(output).to eq(text)

      expect(app.books_path).to eq("/books")
      expect(app.new_book_path).to eq("/books/new")
      expect(app.book_path(1)).to eq("/books/1")
      expect(app.edit_book_path(1)).to eq("/books/1/edit")

      expect(app.new_book_cover_path(1)).to eq("/books/1/cover/new")
      expect(app.book_cover_path(1)).to eq("/books/1/cover")
      expect(app.edit_book_cover_path(1)).to eq("/books/1/cover/edit")
    end

    it "singular to singular" do
      output = draw do
        resource :account do
          resource :avatar
        end
      end
      text = <<~EOL
      account             POST   /account             accounts#create
      new_account         GET    /account/new         accounts#new
      edit_account        GET    /account/edit        accounts#edit
      account             GET    /account             accounts#show
      account             PUT    /account             accounts#update
      account             PATCH  /account             accounts#update
      account             DELETE /account             accounts#destroy
      account_avatar      POST   /account/avatar      avatars#create
      new_account_avatar  GET    /account/avatar/new  avatars#new
      edit_account_avatar GET    /account/avatar/edit avatars#edit
      account_avatar      GET    /account/avatar      avatars#show
      account_avatar      PUT    /account/avatar      avatars#update
      account_avatar      PATCH  /account/avatar      avatars#update
      account_avatar      DELETE /account/avatar      avatars#destroy
      EOL
      expect(output).to eq(text)

      expect(app.new_account_path).to eq("/account/new")
      expect(app.account_path).to eq("/account")
      expect(app.edit_account_path).to eq("/account/edit")

      expect(app.new_account_avatar_path).to eq("/account/avatar/new")
      expect(app.account_avatar_path).to eq("/account/avatar")
      expect(app.edit_account_avatar_path).to eq("/account/avatar/edit")
    end
  end
end

