require "spec_helper"

describe Jets::Router do
  let(:router) do
    Jets::Router.new(routes_path)
  end
  describe "Router" do
    context("main test project") do
      it "builds up routes in memory" do
        # uses fixtures/projects/config/routes.rb
        router = Jets::Router.draw
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Route)

        # router.routes.each do |route|
        #   puts "route.logical_id #{route.logical_id.inspect}"
        #   puts "route.controller_name #{route.controller_name.inspect}"
        # end
        # pp Jets::Router.routes
      end
    end

    context("routes.rb with resources macro") do
      let(:routes_path) { "spec/fixtures/routes/resources.rb" }

      it "expands macro to all the REST routes" do
        router = Jets::Router.new(routes_path)
        router.resources("posts")
        tos = router.routes.map(&:to).sort
        expect(tos).to eq(
          ["posts#create", "posts#delete", "posts#edit", "posts#index", "posts#new", "posts#show", "posts#update"].sort
        )
      end

      it "all_paths list all subpaths" do
        router = Jets::Router.new(routes_path)
        router.evaluate
        expect(router.all_paths).to eq(
          ["landing", "posts", "posts/:id", "posts/:id/edit", "posts/new"]
        )
      end

      it "ordered_routes" do
        router = Jets::Router.new(routes_path)
        router.evaluate
        expect(router.ordered_routes.map(&:path)).to eq(
          ["posts/new", "landing", "posts", "posts", "posts/:id/edit", "posts/:id", "posts/:id", "posts/:id"])
      end
    end
  end
end
