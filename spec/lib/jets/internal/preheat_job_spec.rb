describe Jets::PreheatJob do
  let(:job) do
    Jets::PreheatJob.new({},{},nil)
  end

  context "warm" do
    it "calls all lambda functions with a prewarm request" do
      allow(Jets::Preheat).to receive(:warm_all)
      job.warm
    end
  end
end

