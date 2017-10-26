require 'pp'

class Lam::Build
  autoload :LambdaDeducer, "lam/build/lambda_deducer"
  autoload :HandlerGenerator, "lam/build/handler_generator"
  autoload :TravelingRuby, "lam/build/traveling_ruby"

  def initialize(options)
    @options = options
  end

  def run
    puts "Building project for Lambda..."
    build
  end

  def build
    controller_paths.each do |path|
      deducer = LambdaDeducer.new(path)
      generator = HandlerGenerator.new(deducer.class_name, *deducer.functions)
      generator.run
    end

    TravelingRuby.new.build unless @options[:noop]
  end

  def controller_paths
    paths = []
    expression = "#{Lam.root}app/controllers/**/*.rb"
    Dir.glob(expression).each do |path|
      next unless File.file?(path)
      next if path.include?("application_controller.rb")

      paths << relative_path(path)
    end
    paths
  end

  # Rids of the Lam.root at beginning
  def relative_path(path)
    path.sub(Lam.root, '')
  end
end
