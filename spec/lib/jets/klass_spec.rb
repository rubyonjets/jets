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

  it "from_task" do
    task = Jets::Lambda::Task.new("HardJob", :dig)
    klass = Jets::Klass.from_task(task)
    expect(klass).to eq HardJob

    task = Jets::Lambda::Task.new("Hello", :handler, type: "function")
    klass = Jets::Klass.from_task(task)
    expect(klass).to eq Hello

    task = Jets::Lambda::Task.new("SimpleFunction", :handler, type: "function")
    klass = Jets::Klass.from_task(task)
    expect(klass).to eq SimpleFunction
  end
end

