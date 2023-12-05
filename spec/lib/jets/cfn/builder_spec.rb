describe Jets::Cfn::Builder do
  before(:each) do
    # hack to reset subclasses, Stack classes from other specs pollutes it.
    # Dont really want to define a reset_subclasses! method because this is only used for specs.
    Jets::Stack.instance_variable_set(:@subclasses, [])
  end

  context "templates only and fake full" do
    let(:builder) do
      Jets::Cfn::Builder.new(stack_type: :full)
    end

    it "builds templates" do
      allow(Jets).to receive(:s3_bucket).and_return("demo-test")
      builder.build
      # TODO: cfn build only builds templates now. Need to also copy Jets::PublicFilesController?
      file_exist = File.exist?("/tmp/jets/demo/templates/jets-controller.yml")
      expect(file_exist).to be true
    end
  end

  context "methods" do
    let(:builder) do
      Jets::Cfn::Builder.new(noop: true)
    end

    it "app_file?" do
      yes = Jets::Cfn::Builder.app_file?("app/controllers/posts_controller.rb")
      expect(yes).to be true

      yes = Jets::Cfn::Builder.app_file?("app/jobs/hard_job.rb")
      expect(yes).to be true

      yes = Jets::Cfn::Builder.app_file?("app/functions/hello.rb")
      expect(yes).to be true

      yes = Jets::Cfn::Builder.app_file?("app/models/post.rb")
      expect(yes).to be false
    end
  end

end

