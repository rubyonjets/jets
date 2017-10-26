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
    handlers.each do |handler|
      HandlerGenerator.new(handler).generate
    end

    TravelingRuby.new.build unless @options[:noop]
  end

  def handlers
    handlers = []
    expression = "#{Lam.root}app/controllers/**/*.rb"
    Dir.glob(expression).each do |path|
      next unless File.file?(path)
      next if path.include?("application_controller.rb")

      path = relative_path(path)
      handlers += LambdaDeducer.new(path).deduce.handlers
    end
    # pp handlers
    handlers
  end

  # Rids of the Lam.root at beginning
  def relative_path(path)
    path.sub(Lam.root, '')
  end
end
