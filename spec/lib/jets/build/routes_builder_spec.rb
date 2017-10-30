require "spec_helper"

describe Jets::Build::RoutesBuilder do
  # let(:builder) do
  #   Jets::Build::RoutesBuilder.new
  # end

  describe "RoutesBuilder" do
    it "builds up routes in memory" do
      builder = Jets::Build::RoutesBuilder.draw
      expect(builder.routes.size).to eq 5
      expect(builder.routes.first).to be_a(Jets::Build::Route)

      builder.routes.each do |route|
        puts "route.logical_id #{route.logical_id.inspect}"
        puts "route.controller_name #{route.controller_name.inspect}"
      end

      pp Jets::Build::RoutesBuilder.routes
    end
  end
end
