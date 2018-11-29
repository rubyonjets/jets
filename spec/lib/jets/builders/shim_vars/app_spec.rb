describe Jets::Builders::ShimVars::App do
  context "controller without namespace" do
    let(:vars) do
      Jets::Builders::ShimVars::App.new("app/controllers/posts_controller.rb")
    end

    it "deduces info for node shim" do
      expect(vars.klass).to eq(PostsController)
      expect(vars.process_type).to eq("controller")
      expect(vars.handler_for(:create)).to eq "handlers/controllers/posts_controller.create"
      expect(vars.dest_path).to eq "handlers/controllers/posts_controller.rb"

      expect(vars.functions.sort).to eq(
        [:create, :delete, :edit, :index, :new, :show, :update].sort)
    end
  end

  context "controller with namespace" do
    let(:vars) do
      Jets::Builders::ShimVars::App.new("app/controllers/admin/pages_controller.rb")
    end

    it "deduces info for node shim" do
      expect(vars.klass).to eq(Admin::PagesController)
      expect(vars.process_type).to eq("controller")
      expect(vars.handler_for(:create)).to eq "handlers/controllers/admin/pages_controller.create"
      expect(vars.dest_path).to eq "handlers/controllers/admin/pages_controller.rb"

      expect(vars.functions).to eq [:index]
    end
  end

  context "job" do
    let(:vars) do
      Jets::Builders::ShimVars::App.new("app/jobs/hard_job.rb")
    end

    it "deduces info for node shim" do
      expect(vars.klass).to eq(HardJob)
      expect(vars.process_type).to eq("job")
      expect(vars.handler_for(:dig)).to eq "handlers/jobs/hard_job.dig"
      expect(vars.dest_path).to eq "handlers/jobs/hard_job.rb"

      expect(vars.functions).to eq([:dig, :drive, :lift])
    end
  end

  context "function without _function" do
    let(:vars) do
      Jets::Builders::ShimVars::App.new("app/functions/hello.rb")
    end

    it "deduces info for node shim" do
      expect(vars.klass).to eq(Hello)
      expect(vars.process_type).to eq("function")
      expect(vars.handler_for(:world)).to eq "handlers/functions/hello.world"
      expect(vars.dest_path).to eq "handlers/functions/hello.rb"

      expect(vars.functions).to eq([:world])
    end
  end

  context "function with _function" do
    let(:vars) do
      Jets::Builders::ShimVars::App.new("app/functions/simple_function.rb")
    end

    it "deduces info for node shim" do
      expect(vars.klass).to eq(SimpleFunction)
      expect(vars.process_type).to eq("function")
      expect(vars.handler_for(:world)).to eq "handlers/functions/simple_function.world"
      expect(vars.dest_path).to eq "handlers/functions/simple_function.rb"

      expect(vars.functions).to eq([:handler])
    end
  end
end
