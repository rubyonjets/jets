describe Jets::Cfn::Builders::ControllerBuilder do
  let(:builder) do
    Jets::Cfn::Builders::ControllerBuilder.new(app_class)
  end

  context "PostsController" do
    let(:app_class) { PostsController }
    describe "compose" do
      it "builds a child stack with controller resources" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        resource_types = resources.values.map { |i| i["Type"] }
        expect(resource_types).to include("AWS::Lambda::Function")
        expect(resource_types).to include("AWS::ApiGateway::Method")
        expect(resource_types).to include("AWS::Lambda::Permission")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-app-posts_controller.yml"
      end
    end
  end

  context "StoresController" do
    let(:app_class) { StoresController }
    describe "show function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerShowLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 1024
        # should not transform the keys under Variables section
        keys = properties["Environment"]["Variables"]
        # Just testing for some keys since we keep changing .env files
        test_keys = %w[env_key1 env_key2 global_app_key1 global_app_key2
          ENV_KEY key1 key2 my_test]
        test_keys.each do |test_key|
          expect(keys).to include(test_key)
        end
      end
    end

    describe "index function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerIndexLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 1000
        expect(properties["Timeout"]).to eq 20
      end
    end

    describe "new function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerNewLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 768
      end
    end
  end
end
