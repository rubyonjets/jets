require "spec_helper"

describe "HandlerGenerator" do
  context "controller" do
    let(:generator) do
      Jets::Build::HandlerGenerator.new("app/controllers/posts_controller.rb")
    end

    it "generates a node shim" do
      generator.generate
      content = IO.read("#{Jets.tmpdir}/handlers/controllers/posts.js")
      expect(content).to include("handlers/controllers/posts.create") # handler
      expect(content).to include("exports.create") # 1st function
      expect(content).to include("exports.update") # 2nd function
    end
  end

  context "job" do
    let(:generator) do
      Jets::Build::HandlerGenerator.new("app/jobs/hard_job.rb")
    end

    it "generates a node shim" do
      generator.generate
      content = IO.read("#{Jets.tmpdir}/handlers/jobs/hard.js")
      expect(content).to include("handlers/jobs/hard.dig") # handler
      expect(content).to include("exports.dig")
    end
  end
end
