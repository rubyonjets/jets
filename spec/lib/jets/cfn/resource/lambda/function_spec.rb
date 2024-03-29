describe Jets::Cfn::Resource::Lambda::Function do
  let(:resource) { Jets::Cfn::Resource::Lambda::Function.new(task) }

  context "function timeout 18" do
    let(:task) do
      PostsController.all_public_definitions[:index]
    end
    it "uses function properties" do
      expect(resource.logical_id).to eq "PostsControllerIndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-posts_controller-index"
      expect(properties[:Handler]).to eq "handlers/controllers/posts_controller.index"
    end
  end

  context "function with description specified" do
    let(:task) do
      ArticlesController.all_public_definitions[:index]
    end
    it "uses function properties" do
      expect(resource.logical_id).to eq "ArticlesControllerIndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:Description]).to eq "All articles"
    end
  end

  context "controller" do
    let(:task) do
      PostsController.all_public_definitions[:index]
    end

    it "contains info for CloudFormation Controller Function Resources" do
      expect(resource.logical_id).to eq "PostsControllerIndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-posts_controller-index"
      expect(properties[:Description]).to eq "PostsController#index"
      expect(properties[:Handler]).to eq "handlers/controllers/posts_controller.index"
      expect(properties[:Code][:S3Key]).to include("jets/code")
    end
  end

  context "deeply namespaced controller" do
    module Deep
      module Namespace
        class TestController < Jets::Controller::Base
          def index; end
        end
      end
    end

    let(:task) do
      Deep::Namespace::TestController.all_public_definitions[:index]
    end

    it "contains info for CloudFormation Controller Function Resources" do
      expect(resource.logical_id).to eq "DeepNamespaceTestControllerIndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-deep-namespace-test_controller-index"
      expect(properties[:Description]).to eq "Deep::Namespace::TestController#index"
      expect(properties[:Handler]).to eq "handlers/controllers/deep/namespace/test_controller.index"
      expect(properties[:Code][:S3Key]).to include("jets/code")
    end
  end

  context("job") do
    let(:task) do
      HardJob.all_public_definitions[:dig]
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "HardJobDigLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-hard_job-dig"
      expect(properties[:Description]).to eq "HardJob#dig"
      expect(properties[:Handler]).to eq "handlers/jobs/hard_job.dig"
      expect(properties[:Code][:S3Key]).to include("jets/code")
    end
  end

  context("function with _function") do
    let(:task) do
      Jets::Lambda::Definition.new("SimpleFunction", :lambda_handler)
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "SimpleFunctionLambdaHandlerLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-simple_function-lambda_handler"
      expect(properties[:Description]).to eq "SimpleFunction#lambda_handler"
      expect(properties[:Handler]).to eq "handlers/functions/simple_function.lambda_handler"
      expect(properties[:Code][:S3Key]).to include("jets/code")
    end
  end

  context("function without _function") do
    let(:task) do
      Jets::Lambda::Definition.new("Hello", :world, type: "function")
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "HelloWorldLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:FunctionName]).to eq "demo-test-hello-world"
      expect(properties[:Handler]).to eq "handlers/functions/hello.world"
      expect(properties[:Code][:S3Key]).to include("jets/code")
    end
  end
end

