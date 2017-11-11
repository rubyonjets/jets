require "spec_helper"

describe Jets::Call do
  let(:call) do
    call = Jets::Call.new(function_name, payload, {})
    allow(call).to receive(:lambda).and_return(null)
    call
  end

  let(:function_name) { "posts-controller-index" }
  let(:payload) { "" }
  let(:null) { double(:null).as_null_object }

  it "puts out response payload" do
    call.run
  end
end
