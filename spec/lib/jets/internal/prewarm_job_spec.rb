describe Jets::PrewarmJob do
  let(:job) do
    Jets::PrewarmJob.new(nil,nil,nil)
  end

  context "warm job" do
    it "calls all lambda functions with a prewarm request" do
      job.heat
    end
  end
end

