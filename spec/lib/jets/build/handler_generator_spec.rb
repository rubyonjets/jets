require_relative "../../../spec_helper"

describe Jets::Build::HandlerGenerator do
  let(:generator) do
    Jets::Build::HandlerGenerator.new(
      "PostsController",
      :create, :update
    )
  end

  describe "HandlerGenerator" do
    it "generates a node shim for lambda" do
      generator.run
      content = IO.read("#{Jets.root}handlers/controllers/posts.js")
      expect(content).to include("handlers/controllers/posts.create") # handler
      expect(content).to include("exports.create") # function
      expect(content).to include("exports.update") # function
    end
  end
end
