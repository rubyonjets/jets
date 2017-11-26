require "spec_helper"
require "jets/command/base"

describe Jets::Command do
  let(:null) { double(:null).as_null_object }

  it "help" do
    allow(Jets::Command).to receive(:shell).and_return(null)
    Jets::Command.start(["help"])
  end
end

