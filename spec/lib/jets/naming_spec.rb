describe Jets::Naming do
  it "provides some names used throughout jets" do
    naming = Jets::Naming
    expect(naming.parent_stack_name).to eq "demo-test"
  end
end
