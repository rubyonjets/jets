describe Jets::Names do
  it "provides some names used throughout jets" do
    names = Jets::Names
    expect(names.parent_stack_name).to eq "demo-test"
  end
end
