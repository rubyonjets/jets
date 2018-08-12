describe Jets::Timing::Report do
  let(:report) do
    Jets::Timing::Report.new(log)
  end

  context "update stack" do
    let(:log) { "spec/fixtures/timing/update_stack.log" }
    it "report timing info" do
      output = report.process
      puts output # uncomment to see report and debug
      expect(output).to include("overall:")
    end
  end
end

