require "aws-sdk"

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
    Jets::Cfn::Deploy.new(@options).run
  end
end
