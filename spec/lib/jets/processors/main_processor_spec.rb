describe Jets::Processors::MainProcessor do
  let(:main) { Jets::Processors::MainProcessor.new(event, context, handler) }
  let(:event) { '{"event":"test"}' }
  let(:context) { '{}' }

  context "controller" do
    let(:handler) { 'handlers/controllers/posts_controller.new' }
    it "process:controller event context handler" do
      out = main.run
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data["statusCode"]).to eq "200"
      expect(data["body"]).to eq('{"action":"new"}') # body is JSON encoded String
    end
  end

  context "job" do
    let(:handler) { 'handlers/jobs/hard_job.dig' }
    it "process:job event context handler" do
      out = main.run
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data).to eq("done"=>"digging") # data returned is Hash
    end
  end

  context "function" do
    let(:handler) { 'handlers/functions/hello.world' }
    let(:event) { '{"key1":"value1"}' }
    it "process:function event context handler" do
      out = main.run
      # pp out # uncomment to debug
      data = JSON.parse(out)
      expect(data).to eq 'hello world: "value1"'
    end
  end
end
