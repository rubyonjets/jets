describe "pascalize" do
  it "pascalize keys" do
    h = {foo_bar: 1}
    result = Jets::Pascalize.pascalize(h)
    result.keys == ["FooBar"]
  end

  it "do not pasalize anything under Variables" do
    h = {foo_bar: 1, variables: {dont_touch: 2}}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "Variables"=>{"dont_touch"=>2})
  end

  # CloudWatch Event patterns have slightly different casing
  it "dasherize anything under EventPattern at the top level" do
    h = {foo_bar: 1, event_pattern: {dash_me: 2}}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "EventPattern"=>{"dash-me"=>2})
  end

  it "camelize anything under EventPattern at any level beyond the top level" do
    h = {foo_bar: 1, event_pattern: {dash_me: {camelize_me: 3}}}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "EventPattern"=>{"dash-me"=>{"camelizeMe"=>3}})
  end

  it "dont touch anything under ResponseParameters" do
    h = {foo_bar: 1, response_parameters: {dont_touch: 3}}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "ResponseParameters"=>{"dont_touch"=>3})
  end

  it "dont touch anything with - or /" do
    h = {foo_bar: 1, "has-dash": 2, "has/slash": 3,"application/json":4}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("FooBar"=>1, "has-dash"=>2,"has/slash"=>3,"application/json"=>4)
  end

  it "special map keys" do
    h = {template_url: 1}
    result = Jets::Pascalize.pascalize(h)
    # pp result
    expect(result).to eq("TemplateURL"=>1)
  end
end
