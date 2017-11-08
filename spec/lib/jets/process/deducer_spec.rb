require "spec_helper"

describe "Deducer" do
  context "controller" do
    let(:deducer) do
      Jets::Process::Deducer.new("handlers/controllers/posts.create")
    end

    it "deduces info to run the ruby code" do
      expect(deducer.process_type).to include("controller")
      expect(deducer.path).to include("app/controllers/posts_controller.rb")
      expect(deducer.code).to eq %Q|PostsController.new(event, context, {meth: "create"}).create|
    end
  end

  context "job" do
    let(:deducer) do
      Jets::Process::Deducer.new("handlers/jobs/hard.dig")
    end

    it "deduces info to run the ruby code" do
      expect(deducer.process_type).to include("job")
      expect(deducer.path).to include("app/jobs/hard_job.rb")
      expect(deducer.code).to eq %Q|HardJob.new(event, context, {meth: "dig"}).dig|
    end
  end
end
