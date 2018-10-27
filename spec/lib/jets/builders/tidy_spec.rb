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

      it "excludes should not include jetskeep" do
        expect(tidy.jetskeep).to eq [".bundle", "bundled", "pack", "handlers", "public/assets"]
      end
    end
  end
end
