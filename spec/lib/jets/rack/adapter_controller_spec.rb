describe Jets::Rack::AdapterController do
  let(:controller) do
    controller = Jets::Rack::AdapterController.new(event, {})
    allow(controller).to receive(:app).and_return(rack_app)
    controller
  end

  context "plain rack app" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/show.json") }
    let(:rack_app) do
      Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }
    end
    it "process" do
      pp controller.process
    end
  end
end
