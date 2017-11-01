require "spec_helper"

describe Jets::Build::Router do
  let(:router) do
    Jets::Build::Router.new(routes_path)
  end
  describe "Router" do
    context("main test project") do
      it "builds up routes in memory" do
        # uses fixtures/projects/config/routes.rb
        router = Jets::Build::Router.draw
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Build::Route)

        # router.routes.each do |route|
        #   puts "route.logical_id #{route.logical_id.inspect}"
        #   puts "route.controller_name #{route.controller_name.inspect}"
        # end
        # pp Jets::Build::Router.routes
      end

      it "all_paths has all subpaths" do
        pp Jets::Build::Router.all_paths
      end
    end

    context("routes.rb with resources macro") do
      let(:routes_path) { "fixtures/routes/resources.rb" }
      it "expands macro to all the REST routes" do
        router = Jets::Build::Router.new(routes_path)
        router.resources("posts")
        # pp router.routes
        route_tos = router.routes.map(&:to).sort
        expect(route_tos).to eq(
          %w[posts#index posts#show posts#create posts#edit posts#update posts#delete].sort
        )
      end

      # it "#all_paths list all subpaths" do
      #   router = Jets::Build::Router.new(routes_path)
      #   pp router.evaluate
      #   pp router.all_paths
      # end
    end
  end
end
