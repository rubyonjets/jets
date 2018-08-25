module Jets::Commands
  class Deploy
    include StackInfo
    include Jets::Timing

    def initialize(options)
      @options = options
    end

    def run
      deployment_env = Jets.config.project_namespace.colorize(:green)
      puts "Deploying to Lambda #{deployment_env} environment..."
      return if @options[:noop]

      check_dev_mode
      build_code
      validate_routes!

      # first time will deploy minimal stack
      exit_unless_updateable!

      ship(stack_type: :minimal) if first_run?
      # deploy full nested stack when stack already exists
      ship(stack_type: :full, s3_bucket: s3_bucket)
    end
    time :run

    def check_dev_mode
      if File.exist?("#{Jets.root}dev.mode")
        puts "The dev.mode file exists. Please removed it and run bundle update before you deploy.".colorize(:red)
        exit 1
      end
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end
    time :build_code

    # Checks that all routes are validate and have corresponding lambda functions
    def validate_routes!
      return if Jets::Router.all_routes_valid

      puts "Deploy fail: The jets application contain invalid routes.".colorize(:red)
      puts "Please double check the routes below map to valid controllers:"
      Jets::Router.invalid_routes.each do |route|
        puts "  /#{route.path} => #{route.controller_name}##{route.action_name}"
      end
      exit 1
    end

    def ship(stack_options)
      options = @options.merge(stack_options) # includes stack_type and s3_bucket
      Jets::Commands::Build.new(options).build_templates
      Jets::Cfn::Ship.new(options).run
    end
    time :ship

    # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
    def exit_unless_updateable!
      stack_name = Jets::Naming.parent_stack_name
      exists = stack_exists?(stack_name)
      return unless exists # continue because stack could be updating

      stack = cfn.describe_stacks(stack_name: stack_name).stacks.first
      status = stack["stack_status"]
      if status =~ /^ROLLBACK_/ ||
         status =~ /_IN_PROGRESS$/
        puts "Parent stack associate with this '#{Jets.config.project_name}' project not in a updateable state.".colorize(:red)
        puts "Stack name #{stack_name} status #{stack["stack_status"]}"
        exit
      end
    end
  end
end
