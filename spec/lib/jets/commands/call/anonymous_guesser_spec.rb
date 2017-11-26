require "spec_helper"

describe Jets::Commands::Call::AnonymousGuesser do
  let(:guesser) { Jets::Commands::Call::AnonymousGuesser.new(function_name) }

  context "hello-world function" do
    let(:function_name) { "hello-world" }

    it "class_name and method should be found" do
      expect(guesser.class_name).to eq "Hello"
      expect(guesser.method_name).to eq "world"
      # puts "class_name #{class_name.inspect}"
      # puts "method_name #{method_name.inspect}"
    end

    it "function_filenames" do
      filenames = guesser.function_filenames("hello")
      expect(filenames).to eq([
        "hello" # <= Found path
      ])
    end

    it "function_paths" do
      paths = guesser.function_paths
      expect(paths).to eq([
        "app/functions/hello.rb" # <= Found path
      ])
    end

  end

  context "hello-world2 function" do
    let(:function_name) { "hello-world2" }

    it "method should not be found" do
      expect(guesser.class_name).to eq "Hello"
      expect(guesser.method_name).to be nil
      # puts guesser.error_message
      # expect(guesser.error_message).not_to be nil
      # puts "class_name #{class_name.inspect}"
      # puts "method_name #{method_name.inspect}"
    end
  end

  context "simple-function-handler function" do
    let(:function_name) { "simple-function-handler" }

    it "function_filenames" do
      filenames = guesser.function_filenames("simple_function") # underscored name
      # pp filenames
      expect(filenames).to eq(
        [
          "simple_function",
          "simple/function",
        ]
      )
    end

    it "function_paths" do
      paths = guesser.function_paths
      expect(paths).to eq([
        "app/functions/simple_function.rb", # <= Found path
        "app/functions/simple/function.rb", # <= Found path
      ])
    end
  end

  context "complex-long-name-function-handler function" do
    let(:function_name) { "complex-long-name-function-handler" }

    it "function_filenames" do
      filenames = guesser.function_filenames("complex_long_name_function") # underscored name
      # pp filenames
      expect(filenames).to eq([
        "complex_long_name_function", # ns: nil
                                      # m: complex_long_name_function
        "complex/long_name_function", # ns: complex
                                      # m: long_name_function
        "complex/long/name_function", # ns: complex/long <= IMPORTANT
                                      # m: name_function
        "complex/long/name/function", # ns: complex/long/name
                                      # m: function

        "complex_long/name_function", # ns: complex_long <= IMPORTANT
                                      # m: name_function
        "complex_long/name/function", # ns: complex_long/name
                                      # m: function

        "complex_long_name/function", # ns: complex_long_name
                                      # m: function
      ])

      # Leaving around, useful for understanding
      # primary_namespace = nil
      # paths = guesser.function_filenames("complex_long_name_function", primary_namespace)
      # pp paths

      # primary_namespace = "complex"
      # paths = guesser.function_filenames("complex_long_name_function", primary_namespace)
      # pp paths

      # primary_namespace = "complex_long"
      # paths = guesser.function_filenames("complex_long_name_function", primary_namespace)
      # pp paths
    end
  end
end

