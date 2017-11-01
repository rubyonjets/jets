require "spec_helper"

describe Jets::Build::RoutesBuilder do
  let(:builder) do
    Jets::Build::RoutesBuilder.new(routes_path)
  end
  describe "RoutesBuilder" do
    it "builds up routes in memory" do
      # uses fixtures/projects/config/routes.rb
      builder = Jets::Build::RoutesBuilder.draw
      expect(builder.routes).to be_a(Array)
      expect(builder.routes.first).to be_a(Jets::Build::Route)

      # builder.routes.each do |route|
      #   puts "route.logical_id #{route.logical_id.inspect}"
      #   puts "route.controller_name #{route.controller_name.inspect}"
      # end
      # pp Jets::Build::RoutesBuilder.routes
    end

    context("routes.rb with resources macro") do
      let(:routes_path) { "fixtures/routes/resources.rb" }
      it "expands macro to all the REST routes" do
        builder = Jets::Build::RoutesBuilder.new(routes_path)
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

