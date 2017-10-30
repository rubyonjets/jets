require "spec_helper"

describe Jets::Config do
  describe "jets project config settings" do
    it "have sane defaults" do
      settings = Jets::Config.new.settings
      expect(settings.timeout).to eq 10
      expect(settings.level1.level2).to eq "test"
    end

    it "access to methods via class methods" do
      expect(Jets::Config.runtime).to eq "nodejs6.10"
      expect(Jets::Config.level1.level2).to eq "test"
    end

    it "project_env alias" do
      expect(#{Jets::Config.project_namespace}).to eq "proj-dev-1"
    end
  end
end
