require 'digest'

class Jets::Build
  autoload :Deducer, "jets/build/deducer"
  autoload :HandlerGenerator, "jets/build/handler_generator"
  autoload :LinuxRuby, "jets/build/linux_ruby"
  autoload :TravelingRuby, "jets/build/traveling_ruby"

  def initialize(options)
    @options = options
  end

  def run
    puts "Building project for Lambda..."
    return if @options[:noop]
    build
  end

  def build
    confirm_jets_project

    clean_start # cleans out non-cached files like templates and code-*.zip in Jets.build_root

    # TODO: rename LinuxRuby and TravelingRuby to CodeBuild because it generates note shims too
    # LinuxRuby.new.build unless @options[:noop]
    TravelingRuby.new.build unless @options[:noop]

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

  def build_api_gateway_templates
    gateway = Jets::Cfn::TemplateBuilders::ApiGatewayBuilder.new(@options)
    gateway.build
    deployment = Jets::Cfn::TemplateBuilders::ApiGatewayDeploymentBuilder.new(@options)
    deployment.build
  end

  def build_child_templates
    Jets.boot
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
    app_klass = class_path.classify.constantize # SleepJob

    process_class = path.split('/')[1].singularize.classify # Controller or Job
    builder_class = "Jets::Cfn::TemplateBuilders::#{process_class}Builder".constantize

    # Jets::Cfn::TemplateBuilders::JobBuilder.new(EasyJob) or
    # Jets::Cfn::TemplateBuilders::ControllerBuilder.new(PostsController)
    cfn = builder_class.new(app_klass)
    cfn.build
  end

  def build_parent_template
    parent = Jets::Cfn::TemplateBuilders::ParentBuilder.new(@options)
    parent.build
  end

  # Most files are kept around after the build process for inspection and
  # debugging. So we have to clean out the files. But we only want to clean ou
  # some of the files.
  #
  # Cleans out non-cached files like templates and code-*.zip in Jets.build_root
  # for a clean start.
  #
  def clean_start
    FileUtils.rm_rf("#{Jets.build_root}/templates")
    Dir.glob("#{Jets.build_root}/code/code-*.zip").each { |f| FileUtils.rm_f(f) }
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
      next unless File.file?(path)
      next unless File.extname(path) == ".rb"
      next if path =~ /application_(controller|job).rb/
      next if path !~ %r{app/(controller|job)}

      relative_path = path.sub(Jets.root, '')
      # Rids of the Jets.root at beginning
      paths << relative_path
    end
    paths
  end

  def self.tmp_app_root(full_build_path=false)
    full_build_path ? "#{Jets.build_root}/app_root" : "app_root"
  end

  # Make sure that this command is ran within a jets project
  def confirm_jets_project
    unless File.exist?("#{Jets.root}config/application.yml")
      puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
      exit
    end
  end
end
