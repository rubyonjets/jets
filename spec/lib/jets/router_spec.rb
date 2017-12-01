require "spec_helper"

describe Jets::Router do
  let(:router) { Jets::Router.new }

  describe "Router" do
    context "main test project" do
      it "draw class method" do
        router = Jets::Router.draw
        expect(router).to be_a(Jets::Router)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Route)
      end

      it "builds up routes in memory" do
        # uses fixtures/apps/demo/config/routes.rb
        router.draw do
          resources :articles
          resources :posts
          any "comments/hot", to: "comments#hot"
          get "landing/posts", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Route)

        # router.routes.each do |route|
        #   puts "route.controller_name #{route.controller_name.inspect}"
        #   puts "route.action_name #{route.action_name.inspect}"
        # end
        # pp Jets::Router.routes
      end

      it "root" do
        router.draw do
          root "posts#index"
        end

        route = router.routes.first
        expect(route).to be_a(Jets::Route)
        expect(route.homepage?).to be true
        expect(route.to).to eq "posts#index"
        expect(route.path).to eq ''
        expect(route.method).to eq "GET"
      end
    end

    context "routes with resources macro" do
      it "expands macro to all the REST routes" do
        router.draw do
          resources :posts
        end
        tos = router.routes.map(&:to).sort
        expect(tos).to eq(
          ["posts#create", "posts#delete", "posts#edit", "posts#index", "posts#new", "posts#show", "posts#update"].sort
        )
      end

      it "all_paths list all subpaths" do
        router.draw do
          resources :posts
        end
        # pp router.routes # uncomment to debug
        expect(router.all_paths).to eq(
          ["posts", "posts/:id", "posts/:id/edit", "posts/new"]
        )
      end

      it "ordered_routes should sort by precedence" do
        router.draw do
          resources :posts
          any "*catchall", to: "catch#all"
        end
        expect(router.ordered_routes.map(&:path)).to eq(
          ["posts/new", "posts", "posts", "posts/:id/edit", "posts/:id", "posts/:id", "posts/:id", "*catchall"])

      end
    end
  end
end
