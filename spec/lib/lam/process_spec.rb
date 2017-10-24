require_relative "../../spec_helper"

describe Lam::Process do
  before(:all) do
    # @args = "--noop --project-root spec/fixtures/my_project"
    @args = '\'{ "we" : "love", "using" : "Lambda" }\' \'{"test": "1"}\' "handlers/controllers/posts.create"'
  end

  describe "lam process" do
    it "controller [event] [context] [handler]" do
      out = execute("bin/lam process controller #{@args}")
      pp out
      # expect(out).to include("Creating")
    end
  end
end

