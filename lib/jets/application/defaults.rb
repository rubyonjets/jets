class Jets::Application
  module Defaults
    extend ActiveSupport::Concern

    included do
      def self.default_iam_policy
        project_namespace = Jets.project_namespace
        logs = {
          action: ["logs:*"],
          effect: "Allow",
          resource: "arn:aws:logs:#{Jets.aws.region}:#{Jets.aws.account}:log-group:/aws/lambda/#{project_namespace}-*",
        }
        s3_readonly = {
          action: ["s3:Get*", "s3:List*", "s3:HeadBucket"],
          effect: "Allow",
          resource: "arn:aws:s3:::#{Jets.aws.s3_bucket}*",
        }
        policies = [logs, s3_readonly]

        cloudformation = {
          action: ["cloudformation:DescribeStacks", "cloudformation:DescribeStackResources"],
          effect: "Allow",
          resource: "arn:aws:cloudformation:#{Jets.aws.region}:#{Jets.aws.account}:stack/#{project_namespace}*",
        }
        policies << cloudformation

        if Jets.config.function.vpc_config
          vpc = {
            action: %w[
              ec2:CreateNetworkInterface
              ec2:DeleteNetworkInterface
              ec2:DescribeNetworkInterfaces
              ec2:DescribeVpcs
              ec2:DescribeSubnets
              ec2:DescribeSecurityGroups
            ],
            effect: "Allow",
            resource: "*",
          }
          policies << vpc
        end

        policies
      end
    end

    def default_config
      config = ActiveSupport::OrderedOptions.new
      config.project_name = parse_project_name # must set early because other configs requires this
      config.cors = false
      config.autoload_paths = [] # allows for customization
      config.ignore_paths = [] # allows for customization
      config.logger = Jets::Logger.new($stderr)
      config.time_zone = "UTC"

      # function properties defaults
      config.function = ActiveSupport::OrderedOptions.new
      config.function.timeout = 30
      # default memory setting based on:
      # https://medium.com/epsagon/how-to-make-lambda-faster-memory-performance-benchmark-be6ebc41f0fc
      config.function.memory_size = 1536

      config.prewarm = ActiveSupport::OrderedOptions.new
      config.prewarm.enable = true
      config.prewarm.rate = '30 minutes'
      config.prewarm.concurrency = 2
      config.prewarm.public_ratio = 3
      config.prewarm.rack_ratio = 5

      config.gems = ActiveSupport::OrderedOptions.new
      config.gems.clean = false
      config.gems.disable = false
      config.gems.source = "https://api.serverlessgems.com/api/v1"

      config.inflections = ActiveSupport::OrderedOptions.new
      config.inflections.irregular = {}

      config.assets = ActiveSupport::OrderedOptions.new
      config.assets.folders = %w[assets images packs]
      config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
      config.assets.max_age = 3600
      config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.

      config.ruby = ActiveSupport::OrderedOptions.new

      config.middleware = Jets::Middleware::Configurator.new

      config.session = ActiveSupport::OrderedOptions.new
      config.session.store = Rack::Session::Cookie # note when accessing it use session[:store] since .store is an OrderedOptions method
      config.session.options = {}

      config.api = ActiveSupport::OrderedOptions.new
      config.api.api_key_required = false # Turn off API key required
      config.api.authorization_type = "NONE"
      config.api.auto_replace = nil # https://github.com/boltops-tools/jets/issues/391
      config.api.binary_media_types = ['multipart/form-data']
      config.api.cors_authorization_type = nil # nil so ApiGateway::Cors#cors_authorization_type handles
      config.api.endpoint_policy = nil # required when endpoint_type is EDGE
      config.api.endpoint_type = 'EDGE' # PRIVATE, EDGE, REGIONAL

      config.api.authorizers = ActiveSupport::OrderedOptions.new
      config.api.authorizers.default_token_source = "Auth" # method.request.header.Auth

      config.domain = ActiveSupport::OrderedOptions.new
      # config.domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is nil
      # config.domain.cert_arn = "..."
      config.domain.endpoint_type = "REGIONAL" # EDGE or REGIONAL. Default to EDGE because CloudFormation update is faster
      config.domain.route53 = true # controls whether or not to create the managed route53 record.
        # Useful to disable this when user wants to manage the route themself like pointing
        # it to CloudFront for blue-green deployments instead.

      # Custom user lambda layers
      config.lambda = ActiveSupport::OrderedOptions.new
      config.lambda.layers = []

      # Only used for Jets Afterburner, Mega Mode currently. This is a fallback default
      # encoding.  Usually, the Rails response will return a content-type header and
      # the encoding in there is used when possible. Example Content-Type header:
      #   Content-Type    text/html; charset=utf-8
      config.encoding = ActiveSupport::OrderedOptions.new
      config.encoding.default = "utf-8"

      config.s3_event = ActiveSupport::OrderedOptions.new
      # These notification_configuration properties correspond to the ruby aws-sdk
      #   s3.put_bucket_notification_configuration
      # in jets/s3_bucket_config.rb, not the CloudFormation Bucket properties. The CloudFormation
      # bucket properties have a similiar structure but is slightly different so it can be confusing.
      #
      #   Ruby aws-sdk S3 Docs: https://amzn.to/2N7m5Lr
      config.s3_event.configure_bucket = true
      config.s3_event.notification_configuration = {
        topic_configurations: [
          {
            events: ["s3:ObjectCreated:*"],
            topic_arn: "!Ref SnsTopic", # must use this logical id
          },
        ],
      }

      # So tried to defined this in the jets/mailer.rb Turbine only but jets new requires it
      # config.action_mailer = ActiveSupport::OrderedOptions.new

      config.helpers = ActiveSupport::OrderedOptions.new
      config.helpers.host = nil # nil by default. Other examples: https://myurl.com:8888

      config.controllers = ActiveSupport::OrderedOptions.new
      config.controllers.default_protect_from_forgery = nil
      config.controllers.filtered_parameters = []

      config.app = ActiveSupport::OrderedOptions.new
      config.app.domain = nil

      config.deploy = ActiveSupport::OrderedOptions.new
      config.deploy.stagger = ActiveSupport::OrderedOptions.new
      config.deploy.stagger.enabled = false
      config.deploy.stagger.batch_size = 10

      config.hot_reload = Jets.env.development?

      config.ruby = ActiveSupport::OrderedOptions.new
      config.ruby.check = true

      config
    end

    # Essentially folders under app folder will be the default_autoload_paths. Example:
    #   app/controllers
    #   app/helpers
    #   app/jobs
    #   app/models
    #   app/rules
    #   app/shared/resources
    #
    # Also include:
    #   app/models/concerns
    #   app/controllers/concerns
    def default_autoload_paths
      paths = []
      each_app_autoload_path("#{Jets.root}/app/*") do |path|
        paths << path
      end
      # Handle concerns folders
      each_app_autoload_path("#{Jets.root}/app/**/concerns") do |path|
        paths << path
      end

      paths << "#{Jets.root}/app/shared/resources"
      paths << "#{Jets.root}/app/shared/extensions"

      paths
    end

    def default_ignore_paths
      %w[
        app/functions
        app/shared/functions
      ]
    end
  end
end
