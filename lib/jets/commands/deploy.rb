module Jets::Commands
  class Deploy
    include StackInfo

    def initialize(options)
      @options = options
    end

    def run
      deployment_env = Jets.config.project_namespace.colorize(:green)
      puts "Deploying to Lambda #{deployment_env} environment..."
      return if @options[:noop]

      build_code
      # first time will deploy minimal stack
      exit_if_stack_exists!

      ship(stack_type: :minimal) if first_run?
      # deploy full nested stack when stack already exists
      ship(stack_type: :full, s3_bucket: s3_bucket)
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end

    def ship(stack_options)
      options = @options.merge(stack_options) # includes stack_type and s3_bucket
      Jets::Commands::Build.new(options).build_templates
      Jets::Cfn::Ship.new(options).run
    end

    def exit_if_stack_exists!
      stack_name = Jets::Naming.parent_stack_name
      exists = stack_exists?(stack_name)
      return unless exists

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first
      puts "Parent stack associate with this '#{Jets.config.project_name}' project already exists.".colorize(:red)
      puts "Stack name #{stack_name} status #{stack["stack_status"]}"
      exit
    end
  end
end
