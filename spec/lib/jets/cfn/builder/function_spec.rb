describe Jets::Cfn::Builder::Function do
  let(:builder) do
    Jets::Cfn::Builder::Function.new(klass)
  end

  describe "compose" do
    context "function without _function" do
      let(:klass) do
        Jets::Klass.from_path("app/functions/hello.rb")
      end
      it "builds a child stack with the scheduled events" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        expect(resources).to include("HelloWorldLambdaFunction")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-hello.yml"
      end
    end

    context "function with _function" do
      let(:klass) do
        Jets::Klass.from_path("app/functions/simple_function.rb")
      end
      it "builds a child stack with the scheduled events" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        expect(resources).to include("SimpleFunctionHandlerLambdaFunction")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-simple_function.yml"
      end
    end
  end
end
