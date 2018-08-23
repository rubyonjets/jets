describe "pascalize" do
  it "pascalize keys" do
    h = {"foo_bar" => 1}
    result = Jets::Pascalize.pascalize(h)
    result.keys == ["FooBar"]
  end
end
