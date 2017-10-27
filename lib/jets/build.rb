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

    controller_paths.each do |path|
      build_for(path)
    end
  end

  def build_for(path)
    puts "For: #{path}"
    puts "Building node shim handlers..."
    deducer = LambdaDeducer.new(path)
    generator = HandlerGenerator.new(deducer.class_name, *deducer.functions)
    generator.run

    puts "Building Lambda functions as CloudFormation templates"
    klass = deducer.class_name.constantize # IE: PostsController
    cfn = Jets::Cfn::Builder.new(klass)
    cfn.compose!
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
