describe Jets::Resource::Lambda::Function do
  let(:resource) { Jets::Resource::Lambda::Function.new(task) }

  context "function timeout 18" do
    let(:task) do
      PostsController.all_public_tasks[:index]
    end
    it "uses function properties" do
      expect(resource.logical_id).to eq "IndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["FunctionName"]).to eq "demo-test-posts_controller-index"
      expect(properties["Handler"]).to eq "handlers/controllers/posts_controller.index"
    end
  end

  context "controller" do
    let(:task) do
      PostsController.all_public_tasks[:index]
    end

    it "contains info for CloudFormation Controller Function Resources" do
      expect(resource.logical_id).to eq "IndexLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["FunctionName"]).to eq "demo-test-posts_controller-index"
      expect(properties["Handler"]).to eq "handlers/controllers/posts_controller.index"
      expect(properties["Code"]["S3Key"]).to include("jets/code")
    end
  end

  context("job") do
    let(:task) do
      HardJob.all_public_tasks[:dig]
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "DigLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["FunctionName"]).to eq "demo-test-hard_job-dig"
      expect(properties["Handler"]).to eq "handlers/jobs/hard_job.dig"
      expect(properties["Code"]["S3Key"]).to include("jets/code")
    end
  end

  context("function with _function") do
    let(:task) do
      Jets::Lambda::Task.new("SimpleFunction", :handler)
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "HandlerLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["FunctionName"]).to eq "demo-test-simple_function-handler"
      expect(properties["Handler"]).to eq "handlers/functions/simple_function.handler"
      expect(properties["Code"]["S3Key"]).to include("jets/code")
    end
  end

  context("function without _function") do
    let(:task) do
      Jets::Lambda::Task.new("Hello", :world, type: "function")
    end

    it "contains info for CloudFormation Job Function Resources" do
      expect(resource.logical_id).to eq "WorldLambdaFunction"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["FunctionName"]).to eq "demo-test-hello-world"
      expect(properties["Handler"]).to eq "handlers/functions/hello.world"
      expect(properties["Code"]["S3Key"]).to include("jets/code")
    end
  end
end

