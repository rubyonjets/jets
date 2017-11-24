require "spec_helper"

describe Jets::Cfn::TemplateMappers::LambdaFunctionMapper do
  context "controller" do
    let(:map) do
      Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(task)
    end
    let(:task) do
      Jets::Lambda::Task.new(PostsController, :index)
    end

    describe "map" do
      it "contains info for CloudFormation Controller Function Resources" do
        expect(map.logical_id).to eq "PostsControllerIndexLambdaFunction"
        expect(map.class_action).to eq "PostsControllerIndex"
        expect(map.function_name).to eq "#{Jets.config.project_namespace}-posts_controller-index"
        expect(map.handler).to eq "handlers/controllers/posts_controller.index"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end

  context("job") do
    let(:map) do
      Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(task)
    end
    let(:task) do
      Jets::Lambda::Task.new(HardJob, :perform)
    end

    describe "map" do
      it "contains info for CloudFormation Job Function Resources" do
        expect(map.logical_id).to eq "HardJobPerformLambdaFunction"
        expect(map.class_action).to eq "HardJobPerform"
        expect(map.function_name).to eq "#{Jets.config.project_namespace}-hard_job-perform"
        expect(map.handler).to eq "handlers/jobs/hard_job.perform"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end

  context("function with _function") do
    let(:map) do
      Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(task)
    end
    let(:task) do
      Jets::Lambda::Task.new("HelloFunction", :world)
    end

    describe "map" do
      it "contains info for CloudFormation Job Function Resources" do
        # pp task
        expect(map.logical_id).to eq "HelloFunctionWorldLambdaFunction"
        expect(map.class_action).to eq "HelloFunctionWorld"
        expect(map.function_name).to eq "#{Jets.config.project_namespace}-hello_function-world"
        expect(map.handler).to eq "handlers/functions/hello_function.world"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end

  context("function without _function") do
    let(:map) do
      Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(task)
    end
    let(:task) do
      Jets::Lambda::Task.new("Hello", :world, type: "function")
    end

    describe "map" do
      it "contains info for CloudFormation Job Function Resources" do
        # pp task
        expect(map.logical_id).to eq "HelloWorldLambdaFunction"
        expect(map.class_action).to eq "HelloWorld"
        expect(map.function_name).to eq "#{Jets.config.project_namespace}-hello-world"
        expect(map.handler).to eq "handlers/functions/hello.world"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end
end
