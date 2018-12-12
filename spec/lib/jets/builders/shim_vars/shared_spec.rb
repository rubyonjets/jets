describe Jets::Builders::ShimVars::Shared do
  context "controller without namespace" do
    let(:vars) do
      Jets::Builders::ShimVars::Shared.new(fun)
    end
    let(:functions) do
      functions = []
      Jets::Stack.subclasses.each do |subclass|
        subclass.functions.each do |fun|
          functions << fun
        end
      end
      functions
    end
    let(:fun) { functions.find { |fun| fun.source_file.include?('bob.rb') } }

    it "deduces info for node shim" do
      expect(vars.functions.size).to eq 1
      expect(vars.handler_for(:whatever)).to eq "handlers/shared/functions/bob.js"
      expect(vars.dest_path).to eq "handlers/shared/functions/bob.js"
    end
  end
end