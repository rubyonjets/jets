class Lam::Build
  autoload :LambdaDeducer, "lam/build/lambda_deducer"

  def initialize(options)
    @options = options
    @project_root = ENV['PROJECT_ROOT'] || '.'
  end

  def run
    puts "Building project for Lambda..."
    build
  end

  def build
    deducers = []
    Dir.glob("#{@project_root}/app/controllers/**/*.rb").each do |path|
      next unless File.file?(path)
      next if path.include?("application_controller.rb")

      deducers << LambdaDeducer.new(path)

      p PostsController.superclass
      p PostsController.lambda_functions
      # app/controllers/posts_controller.rb

      puts "path #{path.inspect}"
    end
  end
end
