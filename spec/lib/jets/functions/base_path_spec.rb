require "ostruct"
require "render_me_pretty"

code = RenderMePretty.result("./lib/jets/internal/app/functions/jets/base_path.rb", stage_name: "test")
# Hack to mimic lambda
eval %Q{
class MainScope
  #{code}
end
}

describe "base_path" do
  before do
    allow(CfnResponse).to receive(:new).and_return(null)
  end
  let(:event) { null }
  let(:context) { null }
  let(:null) { double(:null).as_null_object }

  let(:main) do
    MainScope.new
  end

  # mainly test for silly syntax errors
  it "BasePathMapping" do
    main.lambda_handler(event: event, context: context)
  end
end
