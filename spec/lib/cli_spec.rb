require "spec_helper"

# to run specs with what"s remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe Lam::CLI do
  before(:all) do
    @args = "--from Tung"
  end

  describe "lam" do
    it "build" do
      out = execute("bin/lam build")
      # puts out
      expect(out).to include("Building project")
    end
  end
end
