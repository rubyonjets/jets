describe Jets::Shim::Config do
  let :config do
    described_class.instance
  end
  before(:each) do
    config.flush_cache # unmemoize :framework?
  end

  describe "config" do
    it "Rails" do
      Dir.chdir("spec/fixtures/shim/frameworks/rails") do
        expect(config.rails?).to be true
      end
    end
  end
end
