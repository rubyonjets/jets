require "spec_helper"

describe Jets::Process do

  describe "jets process" do
    it "controller [event] [context] [handler]" do
      args = '\'{"we":"love","using":"Lambda"}\' \'{"test":"1"}\' "handlers/controllers/posts.create"'
      out = execute("bin/jets process controller #{args}")
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data["statusCode"]).to eq 200
      expect(data["body"]).to eq('{"a":"create"}')
    end

    it "job [event] [context] [handler]" do
      args = '\'{"we":"love","using":"Lambda"}\' \'{"test":"1"}\' "handlers/jobs/sleep.perform"'
      out = execute("bin/jets process job #{@args}")
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data).to eq('{"work":"done"}')
    end
  end
end
