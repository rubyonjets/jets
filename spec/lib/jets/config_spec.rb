require "spec_helper"

describe Jets::Config do
  it "have good defaults" do
    settings = Jets.config.new.settings
    expect(settings.timeout).to eq 10
    expect(settings.level1.level2).to eq "test"
  end

  it "access to methods via class methods" do
    expect(Jets.config.runtime).to eq "nodejs6.10"
    expect(Jets.config.level1.level2).to eq "test"
  end

  it "project_env alias" do
    expect(Jets.config.project_namespace).to eq "demo-dev-2"
  end
end

