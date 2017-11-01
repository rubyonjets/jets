require "spec_helper"

require "#{Jets.root}app/controllers/application_controller"
require "#{Jets.root}app/controllers/posts_controller"

describe Jets::Naming do
  it "provides some names used throughout jets" do
    naming = Jets::Naming
    expect(naming.parent_stack_name).to eq "proj-dev-2-parent"
  end
end
