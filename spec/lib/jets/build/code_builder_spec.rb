require "spec_helper"

describe Jets::Build::CodeBuilder do
  context "general" do
    let(:builder) do
      Jets::Build::CodeBuilder.new
    end

    it "excludes should not include jetskeep" do
      expect(builder.jetskeep).to eq %w[pack handlers]
      expect(builder.excludes).not_to include("/public/packs")
    end
  end

end
