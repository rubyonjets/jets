describe "Namespace" do
  it "autovivification" do
    Dir.chdir("spec/fixtures/demo") do
      # Sanity check: should not raise an error
      # If it raises an error then module autovivification is not working
      Ns::A
    end
  end
end
