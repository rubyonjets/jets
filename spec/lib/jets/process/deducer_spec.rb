require "spec_helper"

describe "Deducer" do
  context "controller" do
    let(:deducer) do
      Jets::Process::Deducer.new("handlers/controllers/posts.create")
    end

    it "deduces info to run the ruby code" do
      expect(deducer.process_type).to include("controller")
      expect(deducer.path).to include("app/controllers/posts_controller.rb")
      expect(deducer.code).to eq "PostsController.new(event, context).create"
    end
  end

  context "job" do
    let(:deducer) do
      Jets::Process::Deducer.new("handlers/jobs/sleep.perform")
    end

    it "deduces info to run the ruby code" do
      expect(deducer.process_type).to include("job")
      expect(deducer.path).to include("app/jobs/sleep_job.rb")
      expect(deducer.code).to eq "SleepJob.new(event, context).perform"
    end
  end
end
