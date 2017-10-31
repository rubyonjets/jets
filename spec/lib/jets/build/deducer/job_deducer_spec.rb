require "spec_helper"

describe "JobDeducer" do
  let(:deducer) do
    Jets::Build::Deducer::JobDeducer.new("app/jobs/sleep_job.rb")
  end

  it "deduces info for node shim" do
    expect(deducer.class_name).to eq("SleepJob")
    expect(deducer.process_type).to eq("job")
    expect(deducer.handler_for(:perform)).to eq "handlers/jobs/sleep.perform"
    expect(deducer.js_path).to eq "handlers/jobs/sleep.js"
    expect(deducer.cfn_path).to include("sleep-job.yml")

    expect(deducer.functions).to eq([:perform])
  end
end
