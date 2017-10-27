class Jets::Cfn
  class Deploy
    include AwsServices

    def initialize(options)
      @options = options
      @stack_name = "posts-controller" # hard code for testing
      # TODO: @stack_name.  Will eventually be the parent stack only, generate the stack name using the Jets::Project.name
      @template_path = "/tmp/jets_build/templates/#{@stack_name}.yml"
    end

    def capabilities
      ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"] # hardcode
      # return @options[:capabilities] if @options[:capabilities]
      # if @options[:iam]
      #   ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
      # end
    end

    def params
      [
        {
          parameter_key: "LambdaIamRole",
          parameter_value: "arn:aws:iam::160619113767:role/service-role/lambda-test-harness"
        },
        {
          parameter_key: "S3Bucket",
          parameter_value: "boltops-jets"
        }
      ]
    end

    # TODO: move this all into create.rb class
    def create_stack
      template_body = IO.read(@template_path) # TODO: read from s3 only
      cfn.create_stack(
        stack_name: @stack_name,
        template_body: template_body,
        parameters: params,
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
          parameters: params,
          capabilities: capabilities, # ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
          # disable_rollback: !@options[:rollback],
        )
      rescue Aws::CloudFormation::Errors::ValidationError => e
        puts "ERROR: #{e.message}".red
        error = true
      end
    end

    def run
      # PHASE 1
      # template has been generated and available
      # read /tmp/jets_build/templates/posts-controller.yml
      # create or update stack
      # done
      puts "Deploying CloudFormation stack!"
      if stack_exists?(@stack_name)
        update_stack
      else
        create_stack
      end

      # PHASE 2
      # generate parent and child stacks
      # upload templates to s3
      # create or update stack using the s3 parent stack url
      # done

      # PHASE 3
      # create a placeholder stack
      # use changesets to make real updates
      # done
    end
  end
end