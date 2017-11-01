require "spec_helper"

describe Jets::Build::Routes do
  let(:builder) do
    Jets::Build::Routes.new(routes_path)
  end
  describe "Routes" do
    it "builds up routes in memory" do
      # uses fixtures/projects/config/routes.rb
      builder = Jets::Build::Routes.draw
      expect(builder.routes).to be_a(Array)
      expect(builder.routes.first).to be_a(Jets::Build::Route)

      # builder.routes.each do |route|
      #   puts "route.logical_id #{route.logical_id.inspect}"
      #   puts "route.controller_name #{route.controller_name.inspect}"
      # end
      # pp Jets::Build::Routes.routes
    end

    context("routes.rb with resources macro") do
      let(:routes_path) { "fixtures/routes/resources.rb" }
      it "expands macro to all the REST routes" do
        builder = Jets::Build::Routes.new(routes_path)
        builder.resources("posts")
        # pp builder.routes
        route_tos = builder.routes.map(&:to).sort
        expect(route_tos).to eq(
          %w[posts#index posts#show posts#create posts#edit posts#update posts#delete].sort
        )
      end
    end
  end
end

