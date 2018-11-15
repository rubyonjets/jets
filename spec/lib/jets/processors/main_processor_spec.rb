describe Jets::Processors::MainProcessor do
  let(:main) do
    Jets::Processors::MainProcessor.new(
      JSON.dump(event),
      JSON.dump(context),
      handler
    )
  end
  let(:event) { {} }
  let(:context) { {} }

  context "controller create" do
    let(:handler) { 'handlers/controllers/posts_controller.create' }
    it "returns result" do
      result = main.run
      data = JSON.load(result)
      # pp data
      expect(data["statusCode"]).to eq "200"
      expect(data["body"]).to be_a(String)
    end
  end

  context "controller new" do
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
    it "returns result" do
      result = main.run
      data = JSON.load(result)
      # pp data
      expect(data["done"]).to eq "digging"
    end
  end

  context "error job" do
    let(:handler) { 'handlers/jobs/error_job.break' }
    it "throws error" do
      allow(Jets).to receive(:report_exception)
      expect {
        main.run
      }.to raise_error(RuntimeError)
      expect(Jets).to have_received(:report_exception)
    end
  end

  context "function" do
    let(:handler) { 'handlers/functions/hello.world' }
    let(:event) { {"key1" => "value1"} }
    it "returns result" do
      result = main.run
      data = JSON.load(result)
      # pp data
      expect(data).to eq 'hello world: "value1"'
    end
  end

  context "shared function" do
    let(:handler) { 'handlers/shared/functions/whatever.handle' }
    let(:event) { {"key1" => "value1"} }
    it "returns result" do
      result = main.run
      data = JSON.load(result)
      # pp data
      expect(data).to eq 'hello world: "value1"'
    end
  end
end
