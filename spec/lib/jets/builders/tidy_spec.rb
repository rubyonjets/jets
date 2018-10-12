describe Jets::Builders::Tidy do
  context "general" do
    let(:tidy) do
      Jets::Builders::Tidy.new(project_dir, noop: true)
    end

    context "jets app" do
      let(:project_dir) { ENV['JETS_ROOT'] }
      it "cleanup" do
        tidy.cleanup!
      end
    end

    context "rack sub app" do
    end
  end
end
