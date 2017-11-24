require "spec_helper"

describe Jets::Build do
  before(:each) do
    FileUtils.rm_f("spec/fixtures/project/handlers/controllers/posts.js")
  end
  let(:build) do
    Jets::Build.new(noop: true)
  end

  context "running build process" do
    # TODO: figure out way to test build.rb fast
    # it "builds handlers javascript files" do
    #   build.build
    #   file_exist = File.exist?("#{Jets.root}handlers/controllers/posts.js")
    #   expect(file_exist).to be true
    # end

    # Would be nice to be able to automate testing the shim
    # context "node shim" do
    #   it "posts create should return json" do
    #     # build.build
    #     # Dir.chdir(ENV["APP_ROOT"]) do
    #       out = execute("cd #{ENV["APP_ROOT"]} && node handlers/controllers/posts.js")
    #       puts out
    #     # end
    #   end
    # end
  end

  context "methods" do
    it "app_file?" do
      yes = Jets::Build.app_file?("app/controllers/posts_controller.rb")
      expect(yes).to be true

      yes = Jets::Build.app_file?("app/functions/hello.rb")
      expect(yes).to be true

      yes = Jets::Build.app_file?("app/models/post.rb")
      expect(yes).to be false
    end
  end
end

