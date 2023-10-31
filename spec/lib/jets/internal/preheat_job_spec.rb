describe Jets::PreheatJob do
  let(:job) do
    Jets::PreheatJob.new({},{},nil)
  end

  context "IAM policy" do
    it "has a class_iam_policy with lambda::InvokeFunction" do
      expect(Jets::PreheatJob.class_iam_policy).to include(hash_including(
        :Action=>["lambda:InvokeFunction", "lambda:InvokeAsync"]
      ))
    end
  end

  context "warm" do
    it "calls all lambda functions with a prewarm request" do
      allow(Jets::Preheat).to receive(:warm_all)
      job.warm
    end
  end
end

