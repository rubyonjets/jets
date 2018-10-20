describe "HandlerGenerator" do
  context "controller" do
    let(:generator) do
      Jets::Builders::HandlerGenerator.new("app/controllers/posts_controller.rb")
    end

    it "generates a node shim" do
      generator.generate
      # okay to use tmp_app_root because we just have generated it above
      content = IO.read("#{Jets::Commands::Build.tmp_app_root("full")}/handlers/controllers/posts_controller.js")
      expect(content).to include("handlers/controllers/posts_controller.create") # handler
      expect(content).to include("exports.create") # 1st function
      expect(content).to include("exports.update") # 2nd function
    end
  end

  context "job" do
    let(:generator) do
      Jets::Builders::HandlerGenerator.new("app/jobs/hard_job.rb")
    end

    it "generates a node shim" do
      generator.generate
      content = IO.read("#{Jets::Commands::Build.tmp_app_root("full")}/handlers/jobs/hard_job.js")
      expect(content).to include("handlers/jobs/hard_job.dig") # handler
      expect(content).to include("exports.dig")
    end
  end

  context "shared" do
    let(:generator) do
      Jets::Builders::HandlerGenerator.new("path-doesnt-matter-for-shared-resources")
    end

    it "generates the poly native functions" do
      generator.shared_shims
    end
  end
end
