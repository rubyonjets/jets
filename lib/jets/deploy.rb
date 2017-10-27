class Jets::Deploy
  def initialize(options)
    @options = options
  end

  def run
    puts "Deploying project to Lambda..."
    deploy
  end

  def deploy
    Jets::Build.new(@options).run
  end
end
