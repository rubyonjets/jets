class Jets::Cfn
  class Deploy
    include AwsServices

    def initialize(options)
      @options = options
      @stack_name = Namer.parent_stack_name
      @template_path = Namer.parent_template_path
    end

    def run
      puts "Deploying CloudFormation stack!"
      if stack_exists?(@stack_name)
        update_stack
      else
        create_stack
      end
      wait_for_stack
    end

    # TODO: move this all into create.rb class
    def create_stack
      # parent stack from file system, child stacks from s3
      template_body = IO.read(@template_path)
      cfn.create_stack(
        stack_name: @stack_name,
        template_body: template_body,
        capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
        # disable_rollback: !@options[:rollback],
      )
    end

    # TODO: move this all into update.rb class and use changesets as default
    def update_stack
      template_body = IO.read(@template_path)
      begin
        cfn.update_stack(
          stack_name: @stack_name,
          template_body: template_body,
          capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
          # disable_rollback: !@options[:rollback],
        )
      rescue Aws::CloudFormation::Errors::ValidationError => e
        puts "ERROR: #{e.message}".red
        error = true
      end
    end

    # check for _COMPLETE or _FAILED
    def wait_for_stack
      status = ''
      while status !~ /(_COMPLETE|_FAILED)/
        resp = cfn.describe_stacks(stack_name: @stack_name)
        status = resp.stacks[0].stack_status
        sleep 5
        print '.'
      end
      puts
      if status =~ /_FAILED/
        puts "Stack status: #{status}".colorize(:red)
        puts "Stack reason #{resp.stacks[0].stack_reason}".colorize(:red)
      else
        puts "Stack status: #{status}".colorize(:green)
      end
    end

    def capabilities
      return @options[:capabilities] if @options[:capabilities]
      if @options[:iam]
        ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      end
    end
  end
end