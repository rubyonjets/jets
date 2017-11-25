require "spec_helper"

describe Jets::Process::MainProcessor do
  let(:processor) do
    Jets::Process::MainProcessor.new(
      JSON.dump(event),
      JSON.dump(context),
      handler
    )
  end
  let(:event) { {} }
  let(:context) { {} }

  context "controller" do
    let(:handler) { 'handlers/controllers/posts_controller.create' }
    it "returns result" do
      result = processor.run
      data = JSON.load(result)
      # pp data
      expect(data["statusCode"]).to eq 200
      expect(data["body"]).to be_a(String)
    end
  end

  context "job" do
    let(:handler) { 'handlers/jobs/hard_job.dig' }
    it "returns result" do
      result = processor.run
      data = JSON.load(result)
      # pp data
      expect(data["done"]).to eq "digging"
    end
  end

  context "function" do
    let(:handler) { 'handlers/functions/hello.world' }
    let(:event) { {"key1" => "value1"} }
    it "returns result" do
      result = processor.run
      # data = JSON.load(result)
      data = result
      # pp data
      expect(data).to eq 'hello world: "value1"'
    end
  end
end
