require 'action_view'

class Jets::Cfn
  class Deploy
    include AwsServices
    include ActionView::Helpers::NumberHelper # number_to_human_size

    def initialize(options)
      @options = options
      @stack_name = Namer.parent_stack_name
      @template_path = Namer.parent_template_path
    end

    def run
      upload_to_s3 if @options[:s3_bucket] # available when stack_type is not minimal

      puts "Deploying CloudFormation stack!"
      puts "TEST TEST TEST"
      if stack_exists?(@stack_name)
        update_stack
      else
        create_stack
      end
      wait_for_stack
    end

    # Upload both code and child templates to s3
    def upload_to_s3
      bucket_name = @options[:s3_bucket]

      puts "Uploading child CloudFormation templates to S3"
      expression = "#{Jets::Cfn::Namer.template_prefix}-*"
      puts "expression #{expression.inspect}"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        key = "jets/cfn-templates/#{File.basename(path)}"
        obj = s3_resource.bucket(bucket_name).object(key)
        obj.upload_file(path)
      end

      zip_path = Jets::Build.code_zip_file_path
      file_size = number_to_human_size(File.size(zip_path))
      puts "Uploading #{zip_path} (#{file_size}) to S3"
      key = Jets::Cfn::Namer.code_s3_key
      obj = s3_resource.bucket(bucket_name).object(key)
      obj.upload_file(zip_path)
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
      while status !~ /(_COMPLETE|_FAILED)$/
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