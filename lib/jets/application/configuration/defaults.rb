class Jets::Application::Configuration < ::Jets::Engine::Configuration
  # These are Jets specific defaults. The other defaults in Configuration come from using Rails components.
  module Defaults
    extend ActiveSupport::Concern

    attr_accessor :api,
                  :api_mode,
                  :app,
                  :build,
                  :cfn,
                  :controllers,
                  :default_iam_policy,
                  :deploy,
                  :domain,
                  :environment,
                  :events,
                  :filter_parameters,
                  :function,
                  :gems,  # deprecated
                  :helpers_paths,
                  :helpers,
                  :iam_policy,
                  :ignore_paths,
                  :inflections,
                  :lambda,
                  :logger,
                  :logging,
                  :managed_iam_policy,
                  :managed_policy_definitions,
                  :mode,
                  :prewarm,
                  :pro,
                  :routes,
                  :s3_event,
                  :webpacker # deprecated

    def initialize(*)
      Jets::Dotenv.load!
      super
      @api = ActiveSupport::OrderedOptions.new
      @api.api_key_required = false # Turn off API key required
      @api.authorization_type = "NONE"
      @api.authorizers = ActiveSupport::OrderedOptions.new
      @api.authorizers.default_token_source = "Auth" # method.request.header.Auth
      @api.auto_replace = nil # https://github.com/boltops-tools/jets/issues/391
      @api.binary_media_types = ['multipart/form-data']

      @api.cors = default_cors
      @api.endpoint_policy = nil # required when endpoint_type is EDGE
      @api.endpoint_type = 'EDGE' # PRIVATE, EDGE, REGIONAL
      @api.vpc_endpoint_ids = nil

      @api_mode = nil

      @app = ActiveSupport::OrderedOptions.new
      @app.domain = nil

      @build = ActiveSupport::OrderedOptions.new
      @build.prebundle_copy = []

      @cfn = ActiveSupport::OrderedOptions.new
      @cfn.build = ActiveSupport::OrderedOptions.new
      @cfn.build.controllers = "one_lambda_for_all_controllers" # also: one_lambda_per_controller one_lambda_for_all_controllers
      @cfn.build.resource_tags = {} # tags to add to all resources
      @cfn.build.routes = "one_apigw_method_for_all_routes" # also: one_apigw_method_per_route

      @controllers = ActiveSupport::OrderedOptions.new
      @controllers.default_protect_from_forgery = nil

      @deploy = ActiveSupport::OrderedOptions.new
      @deploy.stagger = ActiveSupport::OrderedOptions.new
      @deploy.stagger.enabled = false
      @deploy.stagger.batch_size = 10

      # @domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is nil
      # @domain.cert_arn = "..."
      # @domain.route53 controls whether or not to create the managed route53 record.
      # Useful to disable this when user wants to manage the route themself like pointing
      # it to CloudFront for blue-green deployments instead.
      @domain = ActiveSupport::OrderedOptions.new
      @domain.base_path = '' # empty path represents root
      @domain.endpoint_type = "REGIONAL" # EDGE or REGIONAL. Default to EDGE because CloudFormation update is faster
      @domain.route53 = true

      @environment = ActiveSupport::OrderedOptions.new

      @events = ActiveSupport::OrderedOptions.new

      @events.dynamodb = ActiveSupport::OrderedOptions.new
      @events.dynamodb.table_namespace = true # true will use Jets.table_name
      @events.dynamodb.table_namespace_separator = '_'

      @events.s3 = ActiveSupport::OrderedOptions.new
      @events.s3.configure_bucket = true
      # These notification_configuration properties correspond to the ruby aws-sdk
      #   s3.put_bucket_notification_configuration
      # in jets/s3_bucket.rb, not the CloudFormation Bucket properties. The CloudFormation
      # bucket properties have a similiar structure but is slightly different so it can be confusing.
      #
      #   Ruby aws-sdk S3 Docs: https://amzn.to/2N7m5Lr
      @events.s3.notification_configuration = {
        topic_configurations: [
          {
            events: ["s3:ObjectCreated:*"],
            topic_arn: "!Ref SnsTopic", # must use this logical id
          },
        ],
      }

      # Deprecated: Use @events.s3.configure_bucket instead
      # Leaving in as a comment for now. Will remove comment in the future
      # Already print a deprecation warning in jets/stack/s3_event.rb
      @s3_event = ActiveSupport::OrderedOptions.new
      # @s3_event.configure_bucket = true
      # @s3_event.notification_configuration = {
      #   topic_configurations: [
      #     {
      #       events: ["s3:ObjectCreated:*"],
      #       topic_arn: "!Ref SnsTopic", # must use this logical id
      #     },
      #   ],
      # }

      @filter_parameters = []

      # default function.memory_size memory setting based on:
      # https://medium.com/epsagon/how-to-make-lambda-faster-memory-performance-benchmark-be6ebc41f0fc
      @function = ActiveSupport::OrderedOptions.new
      @function.ephemeral_storage = { size: 512 } # megabytes
      @function.memory_size = 1536
      @function.timeout = 30

      # Old deprecated
      @gems = ActiveSupport::OrderedOptions.new
      @gems.clean = false
      @gems.disable = false
      @gems.source = "https://api.serverlessgems.com/api/v1"
      # New
      @pro = ActiveSupport::OrderedOptions.new
      @pro.disable = false

      @helpers = ActiveSupport::OrderedOptions.new
      @helpers.host = nil # nil by default. Other examples: https://myurl.com:8888
      @helpers_paths = []

      @inflections = ActiveSupport::OrderedOptions.new
      @inflections.irregular = {}

      # Custom user lambda layers
      @lambda = ActiveSupport::OrderedOptions.new
      @lambda.layers = []

      @logger = ActiveSupport::Logger.new($stderr)
      @logger.formatter = ActiveSupport::Logger::SimpleFormatter.new # jets v5 default: no timestamps
      @logger.level = :debug # Logger::DEBUG - default to debug for development mode and to see ActionMailer logs

      @logging = ActiveSupport::OrderedOptions.new
      @logging.event = false # jets v5 behavior

      @mode = nil # job api html

      @prewarm = ActiveSupport::OrderedOptions.new
      @prewarm.enable = true
      @prewarm.public_ratio = 3
      @prewarm.rate = '30 minutes'

      @routes = ActiveSupport::OrderedOptions.new
      @routes.allow_sibling_conflicts = true # users/:id and users/:user_id/articles

      @default_iam_policy = self.class.default_iam_policy
      @managed_policy_definitions = []
      @managed_iam_policy = []
    end

    # IAM policies must run lazily because they depend on @function.vpc_config
    # Need the if Jets.application check because commands like
    #   jets generate kingsman:controllers -h
    # will load Rails for generators and that will directly use a
    # Jets config that does not call Jest.boot
    # See: Jets::Generator
    def iam_policy
      return [] unless Jets.application

      if @default_iam_policy.nil? && @iam_policy.nil?
        return self.class.default_iam_policy
      end

      policy = []
      policy << @default_iam_policy
      if @function.vpc_config
        policy << vpc_iam_policy_statement
      end
      policy << @iam_policy
      policy.flatten.compact
    end

    def vpc_iam_policy_statement
      {
        Action: %w[
          ec2:CreateNetworkInterface
          ec2:DeleteNetworkInterface
          ec2:DescribeNetworkInterfaces
          ec2:DescribeVpcs
          ec2:DescribeSubnets
          ec2:DescribeSecurityGroups
        ],
        Effect: "Allow",
        Resource: "*",
      }
    end

    def default_cors
      !!Gem.loaded_specs.detect do |gem_name, spec|
        gem_name == "rack-cors"
      end
    end

    class_methods do
      def default_iam_policy
        project_namespace = Jets.project_namespace
        logs = {
          Action: ["logs:*"],
          Effect: "Allow",
          Resource: "arn:aws:logs:#{Jets.aws.region}:#{Jets.aws.account}:log-group:/aws/lambda/#{project_namespace}-*",
        }
        s3_readonly = {
          Action: ["s3:Get*", "s3:List*", "s3:HeadBucket"],
          Effect: "Allow",
          Resource: "arn:aws:s3:::#{Jets.aws.s3_bucket}*",
        }
        policies = [logs, s3_readonly]

        cloudformation = {
          Action: ["cloudformation:DescribeStacks", "cloudformation:DescribeStackResources"],
          Effect: "Allow",
          Resource: "arn:aws:cloudformation:#{Jets.aws.region}:#{Jets.aws.account}:stack/#{project_namespace}*",
        }
        policies << cloudformation

        policies
      end
    end

    def load_defaults(target_version)
      load_rails_defaults "7.0"

      case target_version.to_s
      when "5.0"
        @host_authorization = { exclude: ->(request) do
            request.host =~ /localhost/ || request.domain == "amazonaws.com"
          end
        }
      end
    end
  end
end
