class RouterTestApp
  include Jets::Router::Helpers::NamedRoutes
end

describe Jets::Router do
  let(:route_set)  { Jets::Router::RouteSet.new }
  let(:app)     { RouterTestApp.new }

  describe "Router" do
    context "routes with resources macro" do
      it "expands macro to all the REST routes" do
        output = draw do
          resources :posts
        end
        tos = route_set.routes.map(&:to).sort.uniq
        expect(tos).to eq(
          ["posts#create", "posts#destroy", "posts#edit", "posts#index", "posts#new", "posts#show", "posts#update"].sort
        )
      end

      it "all_paths list all subpaths" do
        output = draw do
          resources :posts
        end
        # pp route_set.routes # uncomment to debug
        expect(route_set.all_paths).to eq(
          ["/posts", "/posts/:id", "/posts/:id/edit", "/posts/new"]
        )
      end

      it "ordered_routes should sort by precedence" do
        output = draw do
          resources :posts
          any "*catchall", to: "catch#all"
        end
        paths = route_set.ordered_routes.map(&:path).uniq
        expect(paths).to eq(
          ["/posts/new", "/posts", "/posts/:id/edit", "/posts/:id", "/*catchall"])
      end

      it "ordered_routes should sort nested resources new before show" do
        output = draw do
          resources :posts do
            resources :comments
          end
          any "*catchall", to: "catch#all"
        end
        paths = route_set.ordered_routes.map(&:path).uniq
        expect(paths.index("/posts/:post_id/comments/new")).to be < paths.index("/posts/:post_id/comments/:id")
      end
    end

    context "direct as" do
      it "logout" do
        output = draw do
          get "exit", to: "sessions#destroy", as: :logout
        end
        text = <<~EOL
        logout GET /exit sessions#destroy
        EOL
        expect(output).to eq(text)
      end

      it "namespace logout" do
        output = draw do
          namespace :users do
            get "exit", to: "sessions#destroy", as: :logout
          end
        end
        text = <<~EOL
        logout_users_sessions GET /users/exit users/sessions#destroy
        EOL
        expect(output).to eq(text)
      end
    end

    context "regular create_route methods" do
      it "resources users posts" do
        output = draw do
          resources :users, only: [] do
            get "posts", to: "posts#index"
            get "posts/new", to: "posts#new"
            get "posts/:id", to: "posts#show"
            post "posts", to: "posts#create"
            get "posts/:id/edit", to: "posts#edit"
            put "posts/:id", to: "posts#update"
            patch "posts/:id", to: "posts#update"
            delete "posts/:id", to: "posts#destroy"
          end
        end
        text = <<~EOL
        users     GET    /users/posts              posts#index
        new_user  GET    /posts/users/new          posts#new
        user      GET    /users/:id/posts/:id      posts#show
        users     POST   /users/posts              posts#create
        edit_user GET    /posts/:id/users/:id/edit posts#edit
        user      PUT    /users/:id/posts/:id      posts#update
        user      PATCH  /users/:id/posts/:id      posts#update
        user      DELETE /users/:id/posts/:id      posts#destroy
        EOL
        expect(output).to eq(text)
      end

      it "posts as articles" do
        output = draw do
          get "posts", to: "posts#index", as: "articles"
          get "posts", to: "posts#list", as: "articles2"
          get "posts/new", to: "posts#new", as: "new_article"
          get "posts/:id", to: "posts#show", as: "article"
          get "posts/:id/edit", to: "posts#edit", as: "edit_article"
          get "posts", to: "posts#no_as" # should not create route
        end
        text = <<~EOL
        articles     GET /posts          posts#index
        articles2    GET /posts          posts#list
        new_article  GET /posts/new      posts#new
        article      GET /posts/:id      posts#show
        edit_article GET /posts/:id/edit posts#edit
        posts        GET /posts          posts#no_as
        EOL
        expect(output).to eq(text)
      end
    end

    context "singular resource nested with plural resources" do
      it "profile posts" do
        output = draw do
          resource :profile do
            resources :posts
          end
        end
        text = <<~EOL
        profile           POST   /profile                profiles#create
        new_profile       GET    /profile/new            profiles#new
        edit_profile      GET    /profile/edit           profiles#edit
        profile           GET    /profile                profiles#show
        profile           PUT    /profile                profiles#update
        profile           PATCH  /profile                profiles#update
        profile           DELETE /profile                profiles#destroy
        profile_posts     GET    /profile/posts          posts#index
        profile_posts     POST   /profile/posts          posts#create
        new_profile_post  GET    /profile/posts/new      posts#new
        edit_profile_post GET    /profile/posts/:id/edit posts#edit
        profile_post      GET    /profile/posts/:id      posts#show
        profile_post      PUT    /profile/posts/:id      posts#update
        profile_post      PATCH  /profile/posts/:id      posts#update
        profile_post      DELETE /profile/posts/:id      posts#destroy
        EOL
        expect(output).to eq(text)
      end

      it "posts profile" do
        output = draw do
          resources :posts do
            resource :profile
          end
        end
        text = <<~EOL
        posts             GET    /posts                       posts#index
        posts             POST   /posts                       posts#create
        new_post          GET    /posts/new                   posts#new
        edit_post         GET    /posts/:id/edit              posts#edit
        post              GET    /posts/:id                   posts#show
        post              PUT    /posts/:id                   posts#update
        post              PATCH  /posts/:id                   posts#update
        post              DELETE /posts/:id                   posts#destroy
        post_profile      POST   /posts/:post_id/profile      profiles#create
        new_post_profile  GET    /posts/:post_id/profile/new  profiles#new
        edit_post_profile GET    /posts/:post_id/profile/edit profiles#edit
        post_profile      GET    /posts/:post_id/profile      profiles#show
        post_profile      PUT    /posts/:post_id/profile      profiles#update
        post_profile      PATCH  /posts/:post_id/profile      profiles#update
        post_profile      DELETE /posts/:post_id/profile      profiles#destroy
        EOL
        expect(output).to eq(text)
      end
    end

    context "infer to option" do
      it "credit cards" do
        output = draw do
          get "credit_cards/open"
          get "credit_cards/debit"
          get "credit_cards/credit"
          get "credit_cards/close"
        end
        text = <<~EOL
        credit_cards_open   GET /credit_cards/open   credit_cards#open
        credit_cards_debit  GET /credit_cards/debit  credit_cards#debit
        credit_cards_credit GET /credit_cards/credit credit_cards#credit
        credit_cards_close  GET /credit_cards/close  credit_cards#close
        EOL
        expect(output).to eq(text)
      end
    end
  end
end
