require "spec_helper"

describe Jets::Processors do
  describe "jets" do
    it "process:controller event context handler" do
      args = %Q|'{"event":"test"}' '{}' handlers/controllers/posts_controller.new|
      out = execute("exe/jets process:controller #{args}")
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data["statusCode"]).to eq 200
      expect(data["body"]).to eq('{"action":"new"}') # body is JSON encoded String
    end

    it "process:job event context handler" do
      args = %Q|'{"event":"test"}' '{}' handlers/jobs/hard_job.dig|
      out = execute("exe/jets process:job #{args}")
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data).to eq("done"=>"digging") # data returned is Hash
    end

    it "process:function event context handler" do
      args = %Q|'{"key1":"value1"}' '{}' handlers/functions/hello.world|
      out = execute("exe/jets process:function #{args}")
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data).to eq 'hello world: "value1"'
    end
  end
end
