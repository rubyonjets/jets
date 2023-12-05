describe Jets::Klass do
  it "class_name" do
    class_name = Jets::Klass.class_name("app/functions/hello_function.rb")
    expect(class_name).to eq "HelloFunction"

    class_name = Jets::Klass.class_name("app/functions/hello.rb")
    expect(class_name).to eq "Hello"
  end

  it "from_path" do
    klass = Jets::Klass.from_path("app/functions/hello.rb")
    expect(klass).to eq Hello

    klass = Jets::Klass.from_path("app/controllers/posts_controller.rb")
    expect(klass).to eq PostsController
  end

  it "from_definition" do
    definition = Jets::Lambda::Definition.new("HardJob", :dig)
    klass = Jets::Klass.from_definition(definition)
    expect(klass).to eq HardJob

    definition = Jets::Lambda::Definition.new("Hello", :handler, type: "function")
    klass = Jets::Klass.from_definition(definition)
    expect(klass).to eq Hello

    definition = Jets::Lambda::Definition.new("SimpleFunction", :handler, type: "function")
    klass = Jets::Klass.from_definition(definition)
    expect(klass).to eq SimpleFunction
  end
end

