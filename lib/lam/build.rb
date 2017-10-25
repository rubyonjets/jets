require 'pp'

class Lam::Build
  autoload :LambdaDeducer, "lam/build/lambda_deducer"

  def initialize(options)
    @options = options
  end

  def run
    puts "Building project for Lambda..."
    build
  end

  def build
    handlers
  end

  def handlers
    handlers = []
    puts "Lam.project_root #{Lam.project_root.inspect}"
    expression = "#{Lam.project_root}app/controllers/**/*.rb"
    puts "expression #{expression}"
    Dir.glob(expression).each do |path|
      puts "build path #{path.inspect}"
      next unless File.file?(path)
      next if path.include?("application_controller.rb")

      path = relative_path(path)
      handlers += LambdaDeducer.new(path).deduce.handlers
    end
    pp handlers
    handlers
  end

  # Gets rid of the Lam.project_root
  def relative_path(path)
    path.sub(Lam.project_root, '')
  end
end
