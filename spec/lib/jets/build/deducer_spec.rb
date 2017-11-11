require "spec_helper"

describe Jets::Build::Deducer do
  context "controller" do
    let(:deducer) do
      Jets::Build::Deducer.new("app/controllers/posts_controller.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.class_name).to eq("PostsController")
      expect(deducer.process_type).to eq("controller")
      expect(deducer.handler_for(:create)).to eq "handlers/controllers/posts.create"
      expect(deducer.js_path).to eq "handlers/controllers/posts.js"

      expect(deducer.functions).to eq(
        [:create, :delete, :edit, :index, :new, :show, :update].sort)
    end
  end

  context "controller with namespace" do
    let(:deducer) do
      Jets::Build::Deducer.new("app/controllers/admin/pages_controller.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.class_name).to eq("Admin::PagesController")
      expect(deducer.process_type).to eq("controller")
      expect(deducer.handler_for(:create)).to eq "handlers/controllers/admin/pages.create"
      expect(deducer.js_path).to eq "handlers/controllers/admin/pages.js"

      expect(deducer.functions).to eq [:index]
    end
  end

  context "job" do
    let(:deducer) do
      Jets::Build::Deducer.new("app/jobs/hard_job.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.class_name).to eq("HardJob")
      expect(deducer.process_type).to eq("job")
      expect(deducer.handler_for(:dig)).to eq "handlers/jobs/hard.dig"
      expect(deducer.js_path).to eq "handlers/jobs/hard.js"

      expect(deducer.functions).to eq([:dig, :drive, :lift])
    end
  end
end
