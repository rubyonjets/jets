require "spec_helper"

describe Jets::Call::Guesser do
  let(:guesser) { Jets::Call::Guesser.new(function_name) }

  context "admin/related_pages_controller-list-all" do
    let(:function_name) { "admin/related_pages_controller-list-all" }

    it "function_name" do
      expect(guesser.function_name).to eq("#{Jets.config.project_namespace}-admin-related_pages_controller-list_all")
    end
  end

  context "admin-related-pages-controller-list-all" do
    let(:function_name) { "admin-related-pages-controller-list-all" }

    it "autoload_paths" do
      paths = guesser.autoload_paths
      expect(paths).to eq([
        "admin_related_pages_controller",
        "admin/related_pages_controller",
        "admin/related/pages_controller",
        "admin/related/pages/controller"
      ])
    end

    it "guess_classes" do
      classes = guesser.guess_classes
      expect(classes).to eq([
        "AdminRelatedPagesController",
        "Admin::RelatedPagesController",
        "Admin::Related::PagesController",
        "Admin::Related::Pages::Controller"
      ])
    end

    it "finds the right class when available" do
      found_class_name = guesser.class_name
      expect(found_class_name).to eq("Admin::RelatedPagesController")
    end

    it "function_name" do
      expect(guesser.function_name).to eq("#{Jets.config.project_namespace}-admin-related_pages_controller-list_all")
    end
  end

  context "posts-controller-index" do
    let(:function_name) { "posts-controller-index" }

    it "method_name" do
      # the controller and acion must actually exists
      expect(guesser.method_name).to eq("index")
    end
  end

  context "does-not-exist" do
    let(:function_name) { "does-not-exist" }

    it "returns nil when class is not found" do
      found_class_name = guesser.class_name
      expect(found_class_name).to be nil
    end
  end

  context "hello-world function" do
    let(:function_name) { "hello-world" }

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

