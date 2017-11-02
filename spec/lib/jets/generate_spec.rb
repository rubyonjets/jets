require "spec_helper"

describe "jets generate" do
  describe "migration" do
    it "creates a migrate" do
      command = "bin/jets generate migration posts --partition-key id:string --sort-key --namespace proj-dev"
      out = execute(command)
      pp out # uncomment to debug
      expect(out).to include("Creating migration")
    end
  end
end
