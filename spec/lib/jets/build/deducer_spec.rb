require "spec_helper"

describe Jets::Builders::Deducer do
  context "controller without namespace" do
    let(:deducer) do
      Jets::Builders::Deducer.new("app/controllers/posts_controller.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.klass).to eq(PostsController)
      expect(deducer.process_type).to eq("controller")
      expect(deducer.handler_for(:create)).to eq "handlers/controllers/posts_controller.create"
      expect(deducer.js_path).to eq "handlers/controllers/posts_controller.js"

      expect(deducer.functions.sort).to eq(
        [:create, :delete, :edit, :index, :new, :show, :update].sort)
    end
  end

  context "controller with namespace" do
    let(:deducer) do
      Jets::Builders::Deducer.new("app/controllers/admin/pages_controller.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.klass).to eq(Admin::PagesController)
      expect(deducer.process_type).to eq("controller")
      expect(deducer.handler_for(:create)).to eq "handlers/controllers/admin/pages_controller.create"
      expect(deducer.js_path).to eq "handlers/controllers/admin/pages_controller.js"

      expect(deducer.functions).to eq [:index]
    end
  end

  context "job" do
    let(:deducer) do
      Jets::Builders::Deducer.new("app/jobs/hard_job.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.klass).to eq(HardJob)
      expect(deducer.process_type).to eq("job")
      expect(deducer.handler_for(:dig)).to eq "handlers/jobs/hard_job.dig"
      expect(deducer.js_path).to eq "handlers/jobs/hard_job.js"

      expect(deducer.functions).to eq([:dig, :drive, :lift])
    end
  end

  context "function without _function" do
    let(:deducer) do
      Jets::Builders::Deducer.new("app/functions/hello.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.klass).to eq(Hello)
      expect(deducer.process_type).to eq("function")
      expect(deducer.handler_for(:world)).to eq "handlers/functions/hello.world"
      expect(deducer.js_path).to eq "handlers/functions/hello.js"

      expect(deducer.functions).to eq([:world])
    end
  end

  context "function with _function" do
    let(:deducer) do
      Jets::Builders::Deducer.new("app/functions/simple_function.rb")
    end

    it "deduces info for node shim" do
      expect(deducer.klass).to eq(SimpleFunction)
      expect(deducer.process_type).to eq("function")
      expect(deducer.handler_for(:world)).to eq "handlers/functions/simple_function.world"
      expect(deducer.js_path).to eq "handlers/functions/simple_function.js"

      expect(deducer.functions).to eq([:handler])
    end
  end
end
