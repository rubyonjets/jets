require_relative "../../../../spec_helper"

describe "JobDeducer" do
  let(:deducer) do
    Jets::Process::Deducer::JobDeducer.new("handlers/jobs/sleep.perform")
  end

  it "deduces path and code" do
    expect(deducer.path).to include("app/jobs/sleep_job.rb")
    expect(deducer.code).to eq "SleepJob.new(event, context).perform"
  end
end
