require "aws-sdk-core"

module Jets::Commands
  class Deploy
    extend Memoist
    include StackInfo
    def initialize(options)
      @options = options
    end

    def run
      deployment_env = Jets.config.project_namespace.color(:green)
      puts "Deploying to Lambda #{deployment_env} environment..."
      return if @options[:noop]

      check_dev_mode
      validate_routes!

      # deploy full nested stack when stack already exists
      # Delete existing rollback stack from previous bad minimal deploy
      delete_minimal_stack if minimal_rollback_complete?
      exit_unless_updateable! # Stack could be in a weird rollback state or in progress state

      if first_run?
        ship(stack_type: :minimal)
        Jets.application.reload_configs!
      end

      # Build code after the minimal stack because need s3 bucket for assets
      # on_aws? and s3_base_url logic
      # TODO: possible deploy hook point: before_build
      build_code

      # TODO: possible deploy hook point: before_ship
      create_s3_event_buckets
      ship(stack_type: :full, s3_bucket: s3_bucket)
    end

    def create_s3_event_buckets
      buckets = Jets::Job::Base.s3_events.keys
      buckets.each do |bucket|
        Jets::AwsServices::S3Bucket.ensure_exists(bucket)
      end
    end

    def delete_minimal_stack
      puts "Existing stack is in ROLLBACK_COMPLETE state from a previous failed minimal deploy. Deleting stack and continuing."
      cfn.delete_stack(stack_name: stack_name)
      status.wait
      status.reset
    end

    def check_dev_mode
      if File.exist?("#{Jets.root}/dev.mode")
        puts "The dev.mode file exists. Please removed it and run bundle update before you deploy.".color(:red)
        exit 1
      end
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end

    def validate_routes!
      valid = Jets::Router.validate_routes!
      unless valid
        puts "Deploy fail: The jets application contain invalid routes.".color(:red)
        exit 1
      end
    end

    def ship(stack_options)
      options = @options.merge(stack_options) # includes stack_type and s3_bucket
      Jets::Commands::Build.new(options).build_templates
      Jets::Cfn::Ship.new(options).run
    end

    def status
      Jets::Cfn::Status.new(stack_name)
    end
    memoize :status

    def stack_name
      Jets::Naming.parent_stack_name
    end

    # Checks for a few things before deciding to delete the parent stack
    #
    #   * Parent stack status status is ROLLBACK_COMPLETE
    #   * Parent resources are in the DELETE_COMPLETE state
    #
    def minimal_rollback_complete?
      stack = find_stack(stack_name)
      return false unless stack

      return false unless stack.stack_status == 'ROLLBACK_COMPLETE'

      # Finally check if all the minimal resources in the parent template have been deleted
      resp = cfn.describe_stack_resources(stack_name: stack_name)
      resource_statuses = resp.stack_resources.map(&:resource_status).uniq
      resource_statuses == ['DELETE_COMPLETE']
    end

    def find_stack(stack_name)
      resp = cfn.describe_stacks(stack_name: stack_name)
      resp.stacks.first
    rescue Aws::CloudFormation::Errors::ValidationError => e
      # example: Stack with id demo-dev does not exist
      if e.message =~ /Stack with/ && e.message =~ /does not exist/
        nil
      else
        raise
      end
    end

    # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def exit_unless_updateable!
      return if ENV['JETS_FORCE_UPDATEABLE'] # useful for debugging if stack stack updating

      stack_name = Jets::Naming.parent_stack_name
      exists = stack_exists?(stack_name)
      return unless exists # continue because stack could be updating

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first
      status = stack["stack_status"]
      if status =~ /^ROLLBACK_/ ||
         status =~ /_IN_PROGRESS$/
        region = `aws configure get region`.strip rescue "us-east-1"
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
        puts "The parent stack of the #{Jets.config.project_name.color(:green)} project is not in an updateable state."
        puts "Stack name #{stack_name.color(:yellow)} status #{stack["stack_status"].color(:yellow)}"
        puts "Here's the CloudFormation url to check for more details #{url}"
        exit 1
      end
    end
  end
end
