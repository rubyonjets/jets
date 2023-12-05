describe Jets::Cfn::Builder::Controller do
  let(:builder) do
    Jets::Cfn::Builder::Controller.new(app_class)
  end

  def template_resources(template)
    template.deep_symbolize_keys[:Resources]
  end

  context "PostsController" do
    let(:app_class) { PostsController }
    describe "compose" do
      it "builds a child stack with controller resources" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = template_resources(builder.template)
        resource_types = resources.values.map { |i| i[:Type] }
        expect(resource_types).to include("AWS::Lambda::Function")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-posts_controller.yml"
      end
    end
  end

  context "ChildPostsController" do
    let(:app_class) { ChildPostsController }
    describe "compose" do
      it "builds a child stack with controller resources" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = template_resources(builder.template)
        resource_types = resources.values.map { |i| i[:Type] }
        expect(resource_types).to include("AWS::Lambda::Function")
        # didnt hook up a route in the fixture project so no AWS::ApiGateway::Method expected

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-child_posts_controller.yml"
      end
    end
  end

  context "StoresController" do
    let(:app_class) { StoresController }
    describe "show function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = template_resources(builder.template)
        properties = resources[:StoresControllerShowLambdaFunction][:Properties]

        expect(properties[:MemorySize]).to eq 1024
        expect(properties[:EphemeralStorage][:Size]).to eq 512
        # should not transform the keys under Variables section
        keys = properties[:Environment][:Variables]
        # Just testing for some keys since we keep changing .env files
        test_keys = %w[
          ENV_KEY
          env_key1
          env_key2
          global_app_key1
          global_app_key2
          key1
          key2
          my_test
        ]
        test_keys.each do |test_key|
          expect(keys).to include(test_key.to_sym)
        end
      end
    end

    describe "index function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = template_resources(builder.template)
        properties = resources[:StoresControllerIndexLambdaFunction][:Properties]

        expect(properties[:MemorySize]).to eq 1000
        expect(properties[:Timeout]).to eq 20
        expect(properties[:EphemeralStorage][:Size]).to eq 1024
      end
    end

    describe "new function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = template_resources(builder.template)
        properties = resources[:StoresControllerNewLambdaFunction][:Properties]

        expect(properties[:MemorySize]).to eq 768
      end
    end
  end
end
