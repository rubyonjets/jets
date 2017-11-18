require "spec_helper"

describe Jets::Build::LinuxRuby do
  context "general" do
    let(:builder) do
      Jets::Build::LinuxRuby.new
    end

    it "excludes should not include jetskeep" do
      expect(builder.jetskeep).to eq %w[pack]
      expect(builder.excludes).not_to include("/public/packs")
    end
  end

end
