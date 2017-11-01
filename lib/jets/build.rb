require 'digest'

class Jets::Build
  autoload :Deducer, "jets/build/deducer"
  autoload :HandlerGenerator, "jets/build/handler_generator"
  autoload :TravelingRuby, "jets/build/traveling_ruby"
  autoload :Route, "jets/build/route"
  autoload :Routes, "jets/build/routes"

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

    TravelingRuby.new.build unless @options[:noop]

    clean_start # cleans out templates and code-*.zip in /tmp/jets_build/

    puts "Building node shims."
    app_code_paths.each do |path|
      # TODO: print out #{deducer.path} => #{deducer.js_path}" as part of building
      # puts "  #{deducer.path} => #{deducer.js_path}"
      generate_node_shim(path)
    end
    create_zip_file

    # TODO: move this build.rb logic to cfn/builder.rb
    ## CloudFormation templates
    puts "Building Lambda functions as CloudFormation templates."
    # 1. Shared templates - child templates needs them
    build_api_gateway_templates
    # 2. Child templates - parent template needs them
    app_code_paths.each do |path|
      # TODO: print out #{deducer.path} => #{deducer.cfn_path}" as part of building
      build_child_template(path)
    end
    # 3. Finally parent template
    build_parent_template # must be called at the end
  end

  def generate_node_shim(path)
    handler = Jets::Build::HandlerGenerator.new(path)
    handler.generate
  end

  def build_api_gateway_templates
    gateway = Jets::Cfn::Builder::ApiGatewayTemplate.new(@options)
    gateway.build
    deployment = Jets::Cfn::Builder::ApiGatewayDeploymentTemplate.new(@options)
    deployment.build
  end

  # path: app/controllers/comments_controller.rb
  # path: app/jobs/sleep_job.rb
  def build_child_template(path)
    require "#{Jets.root}#{path}" # require "app/jobs/sleep_job.rb"
    app_klass = File.basename(path, ".rb").classify.constantize # SleepJob

    process_class = path.split('/')[1].singularize.classify # Controller or Job
    builder_class = "Jets::Cfn::Builder::#{process_class}Template".constantize

    # Jets::Cfn::Builder::JobTemplate.new(SleepJob)
    cfn = builder_class.new(app_klass)
    cfn.build
  end

  def build_parent_template
    parent = Jets::Cfn::Builder::ParentTemplate.new(@options)
    parent.build
  end

  # Remove any current templates in the tmp build folder for a clean start
  def clean_start
    FileUtils.rm_rf("/tmp/jets_build/templates")
    Dir.glob("/tmp/jets_build/code-*.zip").each { |f| FileUtils.rm_f(f) }
  end

  def app_code_paths
    paths = []
    expression = "#{Jets.root}app/**/**/*.rb"
    Dir.glob(expression).each do |path|
      next unless File.file?(path)
      next if path =~ /application_(controller|job).rb/
      next if path !~ %r{app/(controller|job)}

      paths << relative_path(path)
    end
    paths
  end

  # Rids of the Jets.root at beginning
  def relative_path(path)
    path.sub(Jets.root, '')
  end

  def create_zip_file
    puts 'Creating zip file.'
    Dir.chdir(Jets.root) do
      # TODO: create_zip_file adds unnecessary files like log files. cp and into temp directory and clean the directory up first.
      success = system("zip -rq #{File.basename(temp_code_zipfile)} .")
      dir = File.dirname(md5_code_zipfile)
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      FileUtils.mv(temp_code_zipfile, md5_code_zipfile)
      abort('Creating zip failed, exiting.') unless success
      puts "Zip file created at: #{md5_code_zipfile.colorize(:green)}"
    end
  end

  def temp_code_zipfile
    Jets::Naming.temp_code_zipfile
  end

  def md5_code_zipfile
    Jets::Naming.md5_code_zipfile
  end

  # Make sure that this command is ran within a jets project
  def confirm_jets_project
    unless File.exist?("#{Jets.root}config/application.yml")
      puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
      exit
    end
  end
end
