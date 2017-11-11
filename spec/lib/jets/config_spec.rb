require "spec_helper"

describe Jets::Config do
  it "have sane defaults" do
    settings = Jets.config # is settings
    expect(settings.timeout).to eq 10
    # Tested manually fine. Set up different fixture to test nested structure later.
    # expect(settings.level1.level2).to eq "test"
  end

  it "access to methods via class methods" do
    expect(Jets.config.runtime).to eq "nodejs6.10"
  end

  it "project_env alias" do
    expect(Jets.config.project_namespace).to eq "demo-test-2"
  end
end

