require "spec_helper"

describe "pascalize" do
  it "pascalize keys" do
    h = {"foo_bar" => 1}
    result = Pascalize.pascalize(h)
    result.keys == ["FooBar"]
  end
end
