require "spec_helper"

describe "JobDeducer" do
  let(:deducer) do
    Jets::Build::Deducer::JobDeducer.new("app/jobs/hard_job.rb")
  end

  it "deduces info for node shim" do
    expect(deducer.class_name).to eq("HardJob")
    expect(deducer.process_type).to eq("job")
    expect(deducer.handler_for(:dig)).to eq "handlers/jobs/hard.dig"
    expect(deducer.js_path).to eq "handlers/jobs/hard.js"
    expect(deducer.cfn_path).to include("hard-job.yml")

    expect(deducer.functions).to eq([:dig, :drive, :lift])
  end
end
