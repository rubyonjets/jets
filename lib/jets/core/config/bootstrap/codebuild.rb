class Jets::Core::Config::Bootstrap
  module Codebuild
    attr_accessor :codebuild

    def initialize(*)
      super

      @codebuild = ActiveSupport::OrderedOptions.new
      @codebuild.project = ActiveSupport::OrderedOptions.new
      @codebuild.project.compute_type = {
        ComputeType: "BUILD_GENERAL1_SMALL",
        Image: "aws/codebuild/amazonlinux2-aarch64-standard:3.0",
        Type: "ARM_CONTAINER"
      }
      @codebuild.project.env = ActiveSupport::OrderedOptions.new
      @codebuild.project.env.vars = {}
      @codebuild.project.env.pass = []
      # Be careful about default env.pass
      # Jets::Dotenv will not load these variables as a part of the Lambda Function
      # So we should be specific about what JETS_ vars we want to the codebuild remote runner
      # Should not use regexp /JETS_/
      @codebuild.project.env.default_pass = [
        "JETS_API",
        "JETS_DOCKER_IMAGE",
        "JETS_ENV",
        "JETS_EXTRA",
        "JETS_GO_VERSION",
        "JETS_PROJECT",
        "JETS_REMOTE_VERSION",
        "JETS_RESET"
      ]
      @codebuild.project.env.block = []
      @codebuild.project.environment = {}
      # fleet arn
      @codebuild.project.fleet_override = ENV["JETS_CODEBUILD_FLEET_OVERRIDE"]
      @codebuild.project.timeout_in_minutes = 60

      # CodebuildLambda
      # The only setting that is used for CodeBuildLambda compute_type
      # Using a separate compute_type config because images are required to be different.
      # A shared setting will not work.
      #
      # All other settings are shared between the CodeBuild and CodeBuildLambda projects
      # IE: @codebuild.project.env.vars etc
      # Think this keeps things simpler and easy to understand.
      # IE: Less room for config errors.
      @codebuild.lambda = ActiveSupport::OrderedOptions.new
      @codebuild.lambda.enable = false
      @codebuild.lambda.project = ActiveSupport::OrderedOptions.new
      @codebuild.lambda.project.compute_type = {
        ComputeType: "BUILD_LAMBDA_1GB",
        Image: "aws/codebuild/amazonlinux-aarch64-lambda-standard:ruby3.2",
        Type: "ARM_LAMBDA_CONTAINER"
      }

      @codebuild.fleet = ActiveSupport::OrderedOptions.new
      @codebuild.fleet.base_capacity = 1
      @codebuild.fleet.enable = !!ENV["JETS_CODEBUILD_FLEET_ENABLE"]

      @codebuild.logging = ActiveSupport::OrderedOptions.new
      @codebuild.logging.final_phases = false
      @codebuild.logging.show = "filtered" # filtered or all
      # Note: Do not use .display It's an ActiveSuppport method

      @codebuild.iam = ActiveSupport::OrderedOptions.new
      @codebuild.iam.policy = []
      @codebuild.iam.managed_policy = []
      @codebuild.iam.default_policy = %w[
        apigateway
        application-autoscaling
        cloudformation
        cloudfront
        codebuild
        dynamodb
        ecr
        ecr-public
        ecs
        elasticloadbalancing
        events
        iam
        lambda
        logs
        route53
        s3
        sns
        sqs
        sts:GetServiceBearerToken
        waf
        wafv2
      ]
      @codebuild.iam.default_managed_policy = %w[
        AmazonSSMReadOnlyAccess
        AWSCertificateManagerReadOnly
      ]
      @codebuild.iam.default_vpc_policy = %w[
        ec2
      ]
    end
  end
end
