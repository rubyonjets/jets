class Jets::Build
  autoload :LambdaDeducer, "jets/build/lambda_deducer"
  autoload :HandlerGenerator, "jets/build/handler_generator"
  autoload :TravelingRuby, "jets/build/traveling_ruby"

  def initialize(options)
    @options = options
  end

  def run
    puts "Building project for Lambda..."
    build
  end

  def build
    puts "Building TravelingRuby..."
    TravelingRuby.new.build unless @options[:noop]

    clean_start

    puts "Building node shims..."
    each_deducer do |deducer|
      puts "  #{deducer.path} => #{deducer.js_path}"
      build_shims(deducer)
    end

    puts "Building Lambda functions as CloudFormation templates.."
    each_deducer do |deducer|
      puts "  #{deducer.path} => #{deducer.cfn_path}"
      build_child_template(deducer)
    end
    build_parent_cfn_template
  end

  def build_shims(deducer)
    generator = HandlerGenerator.new(deducer.class_name, *deducer.functions)
    generator.run
  end

  def build_child_template(deducer)
    klass = deducer.class_name.constantize # IE: PostsController
    cfn = Jets::Cfn::Builder::Child.new(klass)
    cfn.compose!
  end

  def build_parent_cfn_template
    parent = Jets::Cfn::Builder::Parent.new
    parent.compose!
  end

  def each_deducer
    controller_paths.each do |path|
      deducer = LambdaDeducer.new(path)
      yield(deducer)
    end
  end

  # Remove any current templates in the tmp build folder for a clean start
  def clean_start
    FileUtils.rm_rf("/tmp/jets_build/templates")
  end

  def controller_paths
    paths = []
    expression = "#{Jets.root}app/controllers/**/*.rb"
    Dir.glob(expression).each do |path|
      next unless File.file?(path)
      next if path.include?("application_controller.rb")

      paths << relative_path(path)
    end
    paths
  end

  # Rids of the Jets.root at beginning
  def relative_path(path)
    path.sub(Jets.root, '')
  end
end
