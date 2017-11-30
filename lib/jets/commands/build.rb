require 'digest'

class Jets::Commands::Build
  include Jets::AwsServices

  def initialize(options)
    @options = options.dup
  end

  def run
    puts "Building project for Lambda..."
    return if @options[:noop]
    build
  end

  def build
    build_code unless @options[:templates_only]
    merge_build_options!
    if first_run?
      build_minimal_stack
    else
      build_all_templates
    end
  end

  def merge_build_options!
    if first_run?
      @options.merge!(stack_type: "minimal")
    else
      resp = check_updatable_status # exit if stack status is not in an updated able state
      output = resp.stacks[0].outputs.find {|o| o.output_key == 'S3Bucket'}
      s3_bucket = output.output_value
      @options.merge!(stack_type: "full", s3_bucket: s3_bucket)
    end
  end

  def first_run?(fresh=true)
    !stack_exists?(parent_stack_name)
  end

  def parent_stack_name
    Jets::Naming.parent_stack_name
  end

  # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
  #
  # Returns resp so we can use it to grab data about the stack without calling api again.
  def check_updatable_status
    # Assumes stack exists
    resp = cfn.describe_stacks(stack_name: parent_stack_name)
    status = resp.stacks[0].stack_status
    if status =~ /_IN_PROGRESS$/
      puts "The '#{parent_stack_name}' stack status is #{status}. " \
           "It is not in an updateable status. Please wait until the stack is ready and try again.".colorize(:red)
      exit 0
    elsif resp.stacks[0].outputs.empty?
      # This Happens when the miminal stack fails at the very beginning.
      # There is no s3 bucket at all.  User should delete the stack.
      puts "The minimal stack failed to create. Please delete the stack first and try again." \
      "You can delete the CloudFormation stack or use the `jets delete` command"
      exit 0
    else
      resp
    end
  end

  def build_code
    Jets::Builders::CodeBuilder.new.build unless @options[:noop]
  end

  def build_all_templates
    clean_templates
    # TODO: move this build.rb logic to cfn/builder.rb
    ## CloudFormation templates
    puts "Building Lambda functions as CloudFormation templates."
    # 1. Shared templates - child templates needs them
    build_api_gateway_templates
    # 2. Child templates - parent template needs them
    build_child_templates
    # 3. Finally parent template
    build_parent_template # must be called at the end
  end

  def build_minimal_stack
    parent = Jets::Cfn::TemplateBuilders::ParentBuilder.new(@options)
    parent.build
  end

  def build_api_gateway_templates
    gateway = Jets::Cfn::TemplateBuilders::ApiGatewayBuilder.new(@options)
    gateway.build
    deployment = Jets::Cfn::TemplateBuilders::ApiGatewayDeploymentBuilder.new(@options)
    deployment.build
  end

  def build_child_templates
    app_files.each do |path|
      build_child_template(path)
    end
  end

  # path: app/controllers/comments_controller.rb
  # path: app/jobs/easy_job.rb
  def build_child_template(path)
    require "#{Jets.root}#{path}" # require "app/jobs/easy_job.rb"
    class_path = path.sub(%r{.*app/\w+/},'').sub(/\.rb$/,'')
    # strip the app/controller/ or app/jobs/ from the string
    # also strip the .rb
    # class_path: admin/pages_controller

    process_class = path.split('/')[1].singularize.classify # Controller or Job
    builder_class = "Jets::Cfn::TemplateBuilders::#{process_class}Builder".constantize

    # Examples:
    #   Jets::Cfn::TemplateBuilders::JobBuilder.new(EasyJob)
    #   Jets::Cfn::TemplateBuilders::ControllerBuilder.new(PostsController)
    #   Jets::Cfn::TemplateBuilders::FunctionBuilder.new(Hello)
    #   Jets::Cfn::TemplateBuilders::FunctionBuilder.new(HelloFunction)
    app_klass = Jets::Klass.from_path(path)
    builder = builder_class.new(app_klass)
    builder.build
  end

  def build_parent_template
    parent = Jets::Cfn::TemplateBuilders::ParentBuilder.new(@options)
    parent.build
  end

  def clean_templates
    FileUtils.rm_rf("#{Jets.build_root}/templates")
  end

  def app_files
    self.class.app_files
  end

  # Crucial that the Dir.pwd is in the tmp_app_root because for
  # because Jets.boot set ups autoload_paths and this is how project
  # classes are loaded.
  def self.app_files
    paths = []
    expression = "#{Jets.root}app/**/**/*.rb"
    Dir.glob(expression).each do |path|
      return false unless File.file?(path)
      next unless app_file?(path)

      relative_path = path.sub(Jets.root.to_s, '')
      # Rids of the Jets.root at beginning
      paths << relative_path
    end
    paths
  end

  def self.app_file?(path)
    return false unless File.extname(path) == ".rb"
    # Do not define lamda functions for the application_controller.rb or
    # application_job.rb
    excludes = %w[
      application_controller.rb
      application_job.rb
    ]
    return false if excludes.detect { |p| path.include?(p) }

    includes = %w[
      app/controllers
      app/jobs
      app/functions
    ]
    return true if includes.detect { |p| path.include?(p) }

    false
  end

  def self.tmp_app_root(full_build_path=false)
    full_build_path ? "#{Jets.build_root}/app_root" : "app_root"
  end

end
