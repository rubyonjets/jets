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

    it "guess_paths" do
      paths = guesser.guess_paths
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

    it "raise error class when is not available" do
      found_class_name = guesser.class_name
      expect(found_class_name).to be nil
    end
  end
end

