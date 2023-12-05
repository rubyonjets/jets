describe Jets::Router do
  let(:route_set) { Jets.application.routes }
  let(:app)       { RouterTestApp.new }

  describe "Router shallow" do
    it "triple nested shallow at the top on resources posts" do
      output = draw do
        resources :posts, shallow: true do
          resources :comments do
            resources :likes
          end
        end
      end
      text = <<~EOL
      posts            GET    /posts                          posts#index
      posts            POST   /posts                          posts#create
      new_post         GET    /posts/new                      posts#new
      edit_post        GET    /posts/:id/edit                 posts#edit
      post             GET    /posts/:id                      posts#show
      post             PUT    /posts/:id                      posts#update
      post             PATCH  /posts/:id                      posts#update
      post             DELETE /posts/:id                      posts#destroy
      post_comments    GET    /posts/:post_id/comments        comments#index
      post_comments    POST   /posts/:post_id/comments        comments#create
      new_post_comment GET    /posts/:post_id/comments/new    comments#new
      edit_comment     GET    /comments/:id/edit              comments#edit
      comment          GET    /comments/:id                   comments#show
      comment          PUT    /comments/:id                   comments#update
      comment          PATCH  /comments/:id                   comments#update
      comment          DELETE /comments/:id                   comments#destroy
      comment_likes    GET    /comments/:comment_id/likes     likes#index
      comment_likes    POST   /comments/:comment_id/likes     likes#create
      new_comment_like GET    /comments/:comment_id/likes/new likes#new
      edit_like        GET    /likes/:id/edit                 likes#edit
      like             GET    /likes/:id                      likes#show
      like             PUT    /likes/:id                      likes#update
      like             PATCH  /likes/:id                      likes#update
      like             DELETE /likes/:id                      likes#destroy
      EOL
      expect(output).to eq(text)
    end

    it "triple nested shallow at the middle on resources comments" do
      output = draw do
        resources :posts do
          resources :comments, shallow: true do
            resources :likes
          end
        end
      end
      text = <<~EOL
      posts            GET    /posts                          posts#index
      posts            POST   /posts                          posts#create
      new_post         GET    /posts/new                      posts#new
      edit_post        GET    /posts/:id/edit                 posts#edit
      post             GET    /posts/:id                      posts#show
      post             PUT    /posts/:id                      posts#update
      post             PATCH  /posts/:id                      posts#update
      post             DELETE /posts/:id                      posts#destroy
      post_comments    GET    /posts/:post_id/comments        comments#index
      post_comments    POST   /posts/:post_id/comments        comments#create
      new_post_comment GET    /posts/:post_id/comments/new    comments#new
      edit_comment     GET    /comments/:id/edit              comments#edit
      comment          GET    /comments/:id                   comments#show
      comment          PUT    /comments/:id                   comments#update
      comment          PATCH  /comments/:id                   comments#update
      comment          DELETE /comments/:id                   comments#destroy
      comment_likes    GET    /comments/:comment_id/likes     likes#index
      comment_likes    POST   /comments/:comment_id/likes     likes#create
      new_comment_like GET    /comments/:comment_id/likes/new likes#new
      edit_like        GET    /likes/:id/edit                 likes#edit
      like             GET    /likes/:id                      likes#show
      like             PUT    /likes/:id                      likes#update
      like             PATCH  /likes/:id                      likes#update
      like             DELETE /likes/:id                      likes#destroy
      EOL
      expect(output).to eq(text)
    end

    it "triple nested shallow at the bottom on resources likes" do
      output = draw do
        resources :posts do
          resources :comments do
            resources :likes, shallow: true
          end
        end
      end
      text = <<~EOL
      posts                 GET    /posts                                         posts#index
      posts                 POST   /posts                                         posts#create
      new_post              GET    /posts/new                                     posts#new
      edit_post             GET    /posts/:id/edit                                posts#edit
      post                  GET    /posts/:id                                     posts#show
      post                  PUT    /posts/:id                                     posts#update
      post                  PATCH  /posts/:id                                     posts#update
      post                  DELETE /posts/:id                                     posts#destroy
      post_comments         GET    /posts/:post_id/comments                       comments#index
      post_comments         POST   /posts/:post_id/comments                       comments#create
      new_post_comment      GET    /posts/:post_id/comments/new                   comments#new
      edit_post_comment     GET    /posts/:post_id/comments/:id/edit              comments#edit
      post_comment          GET    /posts/:post_id/comments/:id                   comments#show
      post_comment          PUT    /posts/:post_id/comments/:id                   comments#update
      post_comment          PATCH  /posts/:post_id/comments/:id                   comments#update
      post_comment          DELETE /posts/:post_id/comments/:id                   comments#destroy
      post_comment_likes    GET    /posts/:post_id/comments/:comment_id/likes     likes#index
      post_comment_likes    POST   /posts/:post_id/comments/:comment_id/likes     likes#create
      new_post_comment_like GET    /posts/:post_id/comments/:comment_id/likes/new likes#new
      edit_like             GET    /likes/:id/edit                                likes#edit
      like                  GET    /likes/:id                                     likes#show
      like                  PUT    /likes/:id                                     likes#update
      like                  PATCH  /likes/:id                                     likes#update
      like                  DELETE /likes/:id                                     likes#destroy
      EOL
      expect(output).to eq(text)
    end
  end
end
