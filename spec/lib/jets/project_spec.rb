require_relative "../../spec_helper"

describe Jets::Project do
  describe "jets project options" do
    it "have sane defaults" do
      options = Jets::Project.new.options
      expect(options.timeout).to eq 10
      expect(options.level1.level2).to eq "test"
    end

    it "access to methods via class methods" do
      expect(Jets::Project.runtime).to eq "nodejs6.10"
      expect(Jets::Project.level1.level2).to eq "test"
    end
  end
end
