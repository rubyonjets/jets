require "spec_helper"

class ToAttrsTest
  def initialize
    @attrs = {"mytest": "here"}
  end
  def to_attrs
    @attrs
  end
end

describe "to_attrs core extension" do
  describe Hash do
    it "should recursively call to_attrs on all values of the Hash" do
      hash = {
        a: ToAttrsTest.new,
        b: {
          c: {
            d: ToAttrsTest.new
          }
        }
      }
      new_hash = hash.to_attrs
      expect(new_hash).to eq({:a=>{:mytest=>"here"}, :b=>{:c=>{:d=>{:mytest=>"here"}}}})
    end
  end

  describe Array do
    it "should call to_attrs on all values of the Array" do
      array = [ToAttrsTest.new, "a", "z"]
      new_array = array.to_attrs
      expect(new_array).to eq([{:mytest=>"here"}, "a", "z"])
    end
  end
end

