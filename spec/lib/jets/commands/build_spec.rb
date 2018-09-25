describe Jets::Commands::Build do
  context "templates only and fake full" do
    let(:build) do
      Jets::Commands::Build.new(templates_only: true, full: true)
    end

    it "builds templates" do
      file_exist = File.exist?("/tmp/jets/demo/templates/demo-test-app-posts_controller.yml")
      expect(file_exist).to be true
    end

    # it "builds handlers javascript files" do
    # end

    # Would be nice to be able to automate testing the shim
    # context "node shim" do
    #   it "posts create should return json" do
    #     # build.build
    #     # Dir.chdir(ENV["JETS_ROOT"]) do
    #       out = execute("cd #{ENV["JETS_ROOT"]} && node handlers/controllers/posts.js")
    #       puts out
    #     # end
    #   end
    # end
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
      expect(files).to eq([])

      router.draw do
        root "jets/welcome#index"
        any "*catchall", to: "jets/public#show"
      end
      files = Jets::Commands::Build.internal_app_files
      files.reject! { |p| p.include?("preheat_job") }
      expect(files.size).to eq 2
    end
  end

end

