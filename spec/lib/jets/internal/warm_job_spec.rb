describe Jets::WarmJob do
  let(:job) do
    Jets::WarmJob.new(nil,nil,nil)
  end

  context "warm job" do
    it "calls all lambda functions with a prewarm request" do
      job.preheat
    end
  end
end

