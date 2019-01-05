describe Jets::Router::Scope do
  context "root level" do
    let(:scope) do
      Jets::Router::Scope.new
    end
    it "scope is has level 1" do
      expect(scope.level).to eq 1
    end
  end

  context "root level with namespace" do
    let(:scope) do
      Jets::Router::Scope.new(namespace: :admin)
    end
    it "scope is has level 1" do
      expect(scope.level).to eq 1
      expect(scope.options[:namespace]).to eq :admin
    end
  end

  context "nested 2nd level" do
    let(:root) do
      Jets::Router::Scope.new
    end
    let(:scope) do
      root.new
    end
    it "scope is has level 2" do
      expect(scope.level).to eq 2
      expect(scope.parent).to eq root
    end
  end
end