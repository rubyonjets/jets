describe Jets::Cfn::Builders::PageBuilder do
  let(:builder) do
    ENV['JETS_APIGW_PAGE_LIMIT'] = '3'
    Jets::Cfn::Builders::PageBuilder.new
  end

  describe "PageBuilder" do
    it "same pages after as before" do
      old_pages = [
        %w[a1 a2],
        %w[b1 b2],
        %w[c1 c2],
      ]
      new_paths = %w[a1 a2 b1 b2 c1 c2]
      allow(builder).to receive(:old_pages).and_return(old_pages)
      allow(builder).to receive(:new_paths).and_return(new_paths)

      pages = builder.build
      expect(pages).to eq(
        [["a1", "a2"], ["b1", "b2"], ["c1", "c2"]]
      )
    end

    it "fill up pages" do
      old_pages = [
        %w[a1 a2],
        %w[b1 b2],
        %w[c1 c2],
      ]
      new_paths = %w[a1 a2 a3 b1 b2 c1 c2 d1]
      allow(builder).to receive(:old_pages).and_return(old_pages)
      allow(builder).to receive(:new_paths).and_return(new_paths)

      pages = builder.build
      expect(pages).to eq(
        [["a1", "a2", "a3"], ["b1", "b2", "d1"], ["c1", "c2"]]
      )
    end

    it "fill up pages with no nils" do
      old_pages = [
        %w[a1],
        %w[b1],
        %w[c1],
      ]
      new_paths = %w[a1 b1 c1 c2 d1 d2 d3 d4]
      allow(builder).to receive(:old_pages).and_return(old_pages)
      allow(builder).to receive(:new_paths).and_return(new_paths)

      pages = builder.build
      expect(pages).to eq(
        [["a1", "c2", "d1"], ["b1", "d2", "d3"], ["c1", "d4"]]
      )
    end

    it "build remaining slices" do
      old_pages = [
        %w[a1 a2],
        %w[b1 b2],
        %w[c1 c2],
      ]
      new_paths = %w[a1 a2 a3 b1 b2 c1 c2 d1 e1 e2 e3 e4 e5]
      allow(builder).to receive(:old_pages).and_return(old_pages)
      allow(builder).to receive(:new_paths).and_return(new_paths)

      pages = builder.build
      expect(pages).to eq(
        [["a1", "a2", "a3"],
         ["b1", "b2", "d1"],
         ["c1", "c2", "e1"],
         ["e2", "e3", "e4"],
         ["e5"]]
      )
    end

    it "no old pages state" do
      old_pages = nil
      new_paths = %w[a1 a2 b1 b2 c1 c2]
      allow(builder).to receive(:old_pages).and_return(old_pages)
      allow(builder).to receive(:new_paths).and_return(new_paths)

      pages = builder.build
      expect(pages).to eq(
        [["a1", "a2", "b1"], ["b2", "c1", "c2"]]
      )
    end
  end
end
