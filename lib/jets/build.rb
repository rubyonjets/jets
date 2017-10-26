require 'pp'

class Jets::Build
  autoload :LambdaDeducer, "jets/build/lambda_deducer"
  autoload :HandlerGenerator, "jets/build/handler_generator"
  autoload :TravelingRuby, "jets/build/traveling_ruby"

  def initialize(options)
    @options = options
  end

  def run
    puts "Building project for Jetsbda..."
    build
  end

  def build
    puts "Building node shim handlers..."
    controller_paths.each do |path|
      deducer = LambdaDeducer.new(path)
      generator = HandlerGenerator.new(deducer.class_name, *deducer.functions)
      generator.run
    end

    puts "Building TravelingRuby..."
    TravelingRuby.new.build unless @options[:noop]
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
