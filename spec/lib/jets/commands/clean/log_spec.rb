describe Jets::Commands::Clean::Log do
  let(:log) do
    log = Jets::Commands::Clean::Log.new
    allow(log).to receive(:log_group_names).and_return(log_group_names)
    allow(log).to receive(:prefix_guess).and_return("demo-dev")
    log
  end
  let(:log_group_names) do
    %w[
      /aws/lambda/demo-dev-2-jets-preheat_job-warm
      /aws/lambda/demo-dev-2-jets-public_controller-show
      /aws/lambda/demo-dev-2-posts_controller-create
      /aws/lambda/demo-dev-2-posts_controller-delete
      /aws/lambda/demo-dev-hard_job-dig
      /aws/lambda/demo-dev-hard_job-lift
      /aws/lambda/demo-dev-jets-preheat_job-torch
      /aws/lambda/demo-dev-jets-preheat_job-warm
      /aws/lambda/demo-dev-posts_controller-create
      /aws/lambda/demo-dev-posts_controller-delete
      /aws/lambda/demo-dev-1-hard_job-dig
      /aws/lambda/demo-dev-1-hard_job-lift
      /aws/lambda/demo-dev-1-jets-preheat_job-torch
      /aws/lambda/demo-dev-1-jets-preheat_job-warm
      /aws/lambda/demo-dev-1-posts_controller-create
      /aws/lambda/demo-dev-1-posts_controller-delete
    ]
  end

  context "log" do
    it "all_prefixes" do
      prefixes = log.send(:all_prefixes, log_group_names)
      expect(prefixes).to eq([
        "/aws/lambda/demo-dev",
        "/aws/lambda/demo-dev-1",
        "/aws/lambda/demo-dev-2"]
      )
    end

    it "keep_prefixes" do
      prefixes = log.send(:keep_prefixes, log_group_names)
      expect(prefixes).to eq([
        "/aws/lambda/demo-dev-1",
        "/aws/lambda/demo-dev-2"]
      )
    end

    it "keep_log_group?" do
      keep = log.send(:keep_log_group?, "/aws/lambda/demo-dev-2-posts_controller-delete")
      expect(keep).to be true
    end
  end
end
