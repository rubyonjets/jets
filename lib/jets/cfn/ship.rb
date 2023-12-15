module Jets::Cfn
  class Ship
    extend Memoist
    include Jets::AwsServices

    def initialize(options)
      @options = options
      @parent_stack_name = Jets::Names.parent_stack_name
    end

    def run
      # s3 bucket is available only when stack_type is full
      upload_to_s3 if @options[:stack_type] == :full

      stack_in_progress?(@parent_stack_name)

      puts "Deploying CloudFormation stack with jets app!"
      begin
        set_resource_tags
        save_stack
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        capabilities = e.message.match(/\[(.*)\]/)[1]
        confirm = prompt_for_iam(capabilities)
        if confirm =~ /^y/
          @options.merge!(capabilities: [capabilities])
          puts "Re-running: #{command_with_iam(capabilities).color(:green)}"
          retry
        else
          puts "Exited"
          exit 1
        end
      end

      success = wait_for_stack
      unless success
        puts <<~EOL
          The Jets application failed to deploy. Jets creates a few CloudFormation stacks to deploy your application.
          The logs above show the CloudFormation parent stack events and points to the stack with the error.
          Please go to the CloudFormation console and look for the specific stack with the error.
          The specific child stack usually shows more detailed information and can be used to resolve the issue.
          Example of checking the CloudFormation console: https://rubyonjets.com/docs/debugging/cloudformation/
        EOL
        exit 1
      end

      save_apigw_state
      prewarm
      clean_deploy_logs
      show_api_endpoint
      show_custom_domain
      create_deployment_record
    end

    def create_deployment_record
      return if @options[:stack_type] == :minimal
      resp = Jets::Cfn::Deployment.new(@options.merge(stack_name: @parent_stack_name)).create
      if resp
        version = resp["version"]
        Jets::Cfn::Upload.new.upload_cfn_templates(version) if version
      end
    end

    def set_resource_tags
      @tags = Jets.config.cfn.build.resource_tags.map { |key, value| { key: key, value: value } }
    end

    def save_stack
      if stack_exists?(@parent_stack_name)
        update_stack
      else
        create_stack
      end
    end

    def create_stack
      # parent stack template is on filesystem and child stacks templates is on s3
      cfn.create_stack(stack_options)
    end

    def update_stack
      begin
        cfn.update_stack(stack_options)
      rescue Aws::CloudFormation::Errors::ValidationError => e
        puts "ERROR: #{e.message}".color(:red)
        true # error
      end
    end

    # options common to both create_stack and update_stack
    def stack_options
      {
        stack_name: @parent_stack_name,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
        # disable_rollback: !@options[:rollback],
        tags: @tags,
      }.merge!(template.stack_option)
    end

    def template
      @template ||= Template.new(Jets::Names.parent_template_path, @options)
    end

    # check for /(_COMPLETE|_FAILED)$/ status
    def wait_for_stack
      Jets::Cfn::Status.new(@options).wait
    end

    def save_apigw_state
      Jets::Router::State.save_apigw_state
    end

    def prewarm
      if ENV['SKIP_PREWARMING']
        puts "Skipping prewarming" # useful for testing
        return
      end
      return unless @options[:stack_type] == :full # s3 bucket is available
      return unless Jets.config.prewarm.enable
      return unless Jets.gem_layer?

      puts "Prewarming application."
      Jets::PreheatJob.prewarm!
    end

    def clean_deploy_logs
      Jets::Commands::Clean::Log.new(@options).clean_deploys
    end

    def endpoint_unavailable?
      return true unless @options[:stack_type] == :full # s3 bucket is available
      return true if Jets::Router.no_routes?
      _, status = stack_status
      return true if status.include?("ROLLBACK")
      return true unless api_gateway
    end

    # Do not memoize this because on first stack run it will be nil
    # It only gets called one more time so just let it get called.
    def api_gateway
      resp = cfn.describe_stack_resources(stack_name: @parent_stack_name)
      resources = resp.stack_resources
      resources.find { |resource| resource.logical_resource_id == "ApiGateway" }
    end
    memoize :api_gateway

    def endpoint_available?
      !endpoint_unavailable?
    end

    def show_api_endpoint
      return unless endpoint_available?

      stack_id = api_gateway["physical_resource_id"]

      resp = cfn.describe_stacks(stack_name: stack_id)
      stack = resp["stacks"].first
      output = stack["outputs"].find { |o| o["output_key"] == "RestApiUrl" }
      endpoint = output["output_value"]
      puts "API Gateway Endpoint: #{endpoint}"
    end

    def show_custom_domain
      return unless endpoint_available? && Jets.custom_domain? && Jets.config.domain.route53

      domain_name = Jets::Cfn::Resource::ApiGateway::DomainName.new
      # Looks funny but its right.
      # domain_name is a method on the Jets::Cfn::Resource::ApiGateway::Domain instance
      url = "https://#{domain_name.domain_name}"
      puts "Custom Domain: #{url}"
      puts "App Domain: https://#{Jets.config.app.domain}" if Jets.config.app.domain
    end

    # All CloudFormation states listed here:
    # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def stack_status
      resp = cfn.describe_stacks(stack_name: @parent_stack_name)
      status = resp.stacks[0].stack_status
      [resp, status]
    end

    def prompt_for_iam(capabilities)
      puts "This stack will create IAM resources.  Please approve to run the command again with #{capabilities} capabilities."
      puts "  #{command_with_iam(capabilities)}"

      puts "Please confirm (y/n)"
      $stdin.gets # confirm
    end

    def command_with_iam(capabilities)
      "#{File.basename($0)} #{ARGV.join(' ')} --capabilities #{capabilities}"
    end

    def capabilities
      ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
    end

    # Upload both code and child templates to s3
    def upload_to_s3
      Upload.new.upload
    end
  end
end
