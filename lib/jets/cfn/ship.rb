class Jets::Cfn
  class Ship
    include Jets::AwsServices

    def initialize(options)
      @options = options
      @parent_stack_name = Jets::Naming.parent_stack_name
      @template_path = Jets::Naming.parent_template_path
    end

    def run
      # s3 bucket is available only when stack_type is full
      upload_to_s3 if @options[:stack_type] == :full

      stack_in_progress?(@parent_stack_name)

      puts "Deploying CloudFormation stack with jets app!"
      begin
        save_stack
      rescue Aws::CloudFormation::Errors::InsufficientCapabilitiesException => e
        capabilities = e.message.match(/\[(.*)\]/)[1]
        confirm = prompt_for_iam(capabilities)
        if confirm =~ /^y/
          @options.merge!(capabilities: [capabilities])
          puts "Re-running: #{command_with_iam(capabilities).colorize(:green)}"
          retry
        else
          puts "Exited"
          exit 1
        end
      end

      wait_for_stack
      prewarm
      show_api_endpoint
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
        puts "ERROR: #{e.message}".red
        true # error
      end
    end

    # options common to both create_stack and update_stack
    def stack_options
      {
        stack_name: @parent_stack_name,
        template_body: IO.read(@template_path),
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
        # disable_rollback: !@options[:rollback],
      }
    end

    # check for /(_COMPLETE|_FAILED)$/ status
    def wait_for_stack
      Jets::Cfn::Status.new(@options).wait
    end

    def prewarm
      if ENV['SKIP_PREWARMING']
        puts "Skipping prewarming" # useful for testing
        return
      end
      return unless @options[:stack_type] == :full # s3 bucket is available
      return unless Jets.config.prewarm.enable
      return if Jets.poly_only?

      puts "Prewarming application."
      if Jets::PreheatJob::CONCURRENCY > 1
        Jets::PreheatJob.perform_now(:torch, {quiet: true})
      else
        Jets::PreheatJob.perform_now(:warm, {quiet: true})
      end
    end

    def show_api_endpoint
      return unless @options[:stack_type] == :full # s3 bucket is available
      return if Jets::Router.routes.empty?
      resp, status = stack_status
      return if status.include?("ROLLBACK")

      resp = cfn.describe_stack_resources(stack_name: @parent_stack_name)
      resources = resp.stack_resources
      api_gateway = resources.find { |resource| resource.logical_resource_id == "ApiGateway" }
      stack_id = api_gateway["physical_resource_id"]

      resp = cfn.describe_stacks(stack_name: stack_id)
      stack = resp["stacks"].first
      output = stack["outputs"].find { |o| o["output_key"] == "RestApiUrl" }
      endpoint = output["output_value"]
      puts "API Gateway Endpoint: #{endpoint}"
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
      ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"] # TODO: remove capabilities hardcode
      # return @options[:capabilities] if @options[:capabilities]
      # if @options[:iam]
      #   ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      # end
    end

    # Upload both code and child templates to s3
    def upload_to_s3
      raise "Did not specify @options[:s3_bucket] #{@options[:s3_bucket].inspect}" unless @options[:s3_bucket]

      uploader = Upload.new(@options[:s3_bucket])
      uploader.upload
    end
  end
end
