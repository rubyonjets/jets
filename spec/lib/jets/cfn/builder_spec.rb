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

    context 'prewarm enabled' do
      before { Jets.config.prewarm.enable = true }


      it 'builds the preheat job template' do
        allow(Jets).to receive(:s3_bucket).and_return("demo-test")
        builder.build

        preheat_job_file_path = "/tmp/jets/demo/templates/app-jets-preheat_job.yml"
        file_exist = File.exist?(preheat_job_file_path)
        expect(file_exist).to be true

        template_hsh = YAML.load(File.read(preheat_job_file_path))
        expect(template_hsh["Resources"].keys).to contain_exactly "JetsPreheatJobIamPolicy",
                                                                  "JetsPreheatJobIamRole",
                                                                  "JetsPreheatJobWarmEventsRule",
                                                                  "JetsPreheatJobWarmLambdaFunction",
                                                                  "JetsPreheatJobWarmPermission"

        rule_schedule = template_hsh.dig("Resources", "JetsPreheatJobWarmEventsRule", "Properties", "ScheduleExpression")
        expect(rule_schedule).to eq "rate(#{Jets.config.prewarm.rate})"
      end
    end

    context 'prewarm disabled' do
      before { Jets.config.prewarm.enable = false }

      it 'does not build the preheat job template' do
        allow(Jets).to receive(:s3_bucket).and_return("demo-test")
        builder.build

        preheat_job_file_path = "/tmp/jets/demo/templates/app-jets-preheat_job.yml"
        file_exist = File.exist?(preheat_job_file_path)
        expect(file_exist).to be_falsey
      end
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

    it "app_files" do
      expect(Jets::Cfn::Builder.app_files).to include("app/controllers/posts_controller.rb")
      expect(Jets::Cfn::Builder.app_files).to include("app/jobs/hard_job.rb")
      expect(Jets::Cfn::Builder.app_files).to include("app/functions/hello.rb")

      expect(Jets::Cfn::Builder.app_files).not_to include("app/models/post.rb")
    end

    context "prewarming enabled" do
      before { Jets.config.prewarm.enable = true }

      it "app_files includes preheat job" do
        expect(Jets::Cfn::Builder.app_files).to include(a_string_ending_with("preheat_job.rb"))
      end
    end

    context "prewarming disabled" do
      before { Jets.config.prewarm.enable = false }

      it "app_files does not include preheat job" do
        expect(Jets.config.prewarm.enabled).to be_falsey
        expect(Jets::Cfn::Builder.app_files).not_to include(a_string_ending_with("preheat_job.rb"))
      end
    end
  end

end

