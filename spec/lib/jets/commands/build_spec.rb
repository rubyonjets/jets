describe Jets::Commands::Build do
  before(:each) do
    # hack to reset subclasses, Stack classes from other specs pollutes it.
    # Dont really want to define a reset_subclasses! method because this is only used for specs.
    Jets::Stack.instance_variable_set(:@subclasses, [])
  end

  context "templates only and fake full" do
    let(:build) do
      Jets::Commands::Build.new(templates: true, full: true)
    end

    it "builds templates" do
      build.run
      file_exist = File.exist?("/tmp/jets/demo/templates/demo-test-app-posts_controller.yml")
      expect(file_exist).to be true
    end
  end

  context "methods" do
    let(:build) do
      Jets::Commands::Build.new(noop: true)
    end

    it "app_file?" do
      yes = Jets::Commands::Build.app_file?("app/controllers/posts_controller.rb")
      expect(yes).to be true

      yes = Jets::Commands::Build.app_file?("app/jobs/hard_job.rb")
      expect(yes).to be true

      yes = Jets::Commands::Build.app_file?("app/functions/hello.rb")
      expect(yes).to be true

      yes = Jets::Commands::Build.app_file?("app/models/post.rb")
      expect(yes).to be false
    end

    it "internal_app_files" do
      router = Jets::Router.drawn_router
      files = Jets::Commands::Build.internal_app_files
      files.reject! { |p| p.include?("preheat_job") }
      files.reject! { |p| p.include?("public_controller") }
      expect(files).to eq([])

      router.draw do
        any "*catchall", to: "jets/public#show"
      end
      files = Jets::Commands::Build.internal_app_files
      files.reject! { |p| p.include?("preheat_job") }
      expect(files.size).to eq 1
    end
  end

end

