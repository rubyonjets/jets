module Jets::Command
  class DeployCommand < Base # :nodoc:
    include EnvironmentArgument

    desc "deploy", "Builds and deploys project to AWS Lambda"
    long_desc Help.text(:deploy)
    option :message, aliases: :m, desc: "Custom message to use for the deployment message"
    def perform
      extract_environment_option_from_argument
      require_application_and_environment!

      stack = Jets.project_namespace.color(:green)
      puts "Deploying stack #{stack} ..."
      return if @options[:noop]

      check_dev_mode
      validate_routes!

      # Delete existing rollback stack from previous bad minimal deploy
      delete_minimal_stack if minimal_rollback_complete?
      exit_unless_updateable! # Stack could be in a weird rollback state or in progress state

      if first_run?
        ship(stack_type: :minimal)
      end

      # Build code after the minimal stack because need s3 bucket for assets on_aws? and s3_base_url logic
      # TODO: possible deploy hook point: before_build
      Jets::Builders::CodeBuilder.new.build

      # TODO: possible deploy hook point: before_ship
      create_s3_event_buckets
      ship(stack_type: :full, s3_bucket: Jets.s3_bucket)
    end

  private
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
      if File.exist?("#{Jets.root}/dev.mode") && !ENV['JETS_SKIP_DEV_MODE_CHECK']
        puts "The dev.mode file exists. Please removed it and run bundle update before you deploy.".color(:red)
        exit 1
      end
    end

    def validate_routes!
      valid = Jets::Router.validate_routes!
      return if valid

      puts "Deploy fail: The jets application contain invalid routes.".color(:red)
      exit 1
    end

    def ship(stack_options)
      options = @options.merge(stack_options) # includes stack_type
      Jets::Cfn::Builder.new(options).build
      Jets::Cfn::Ship.new(options).run
    end

    def status
      @status ||= Jets::Cfn::Status.new(stack_name)
    end

    def stack_name
      Jets::Names.parent_stack_name
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

    # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def exit_unless_updateable!
      return if ENV['JETS_FORCE_UPDATEABLE'] # useful for debugging if stack stack updating

      stack_name = Jets::Names.parent_stack_name
      exists = stack_exists?(stack_name)
      return unless exists # continue because stack could be updating

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first
      status = stack["stack_status"]
      if status =~ /^ROLLBACK_/ ||
          status =~ /_IN_PROGRESS$/
        region = `aws configure get region`.strip rescue "us-east-1"
        url = "https://console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks"
        puts "The parent stack of the #{Jets.project_name.color(:green)} project is not in an updateable state."
        puts "Stack name #{stack_name.color(:yellow)} status #{stack["stack_status"].color(:yellow)}"
        puts "Here's the CloudFormation url to check for more details #{url}"
        exit 1
      end
    end
    end
end
