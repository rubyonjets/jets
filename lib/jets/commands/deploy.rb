class Jets::Commands::Deploy
  def initialize(options)
    @options = options
  end

  def run
    puts "Deploying project to Lambda..."
    return if @options[:noop]
    deploy
  end

  def deploy
    build_code

    if first_run?
      deploy_minimal_stack
      deploy_full_stack
    else
      deploy_full_stack
    end
  end

  def build_code
    Jets::Commands::Build.new(stack_options).build_code
  end

  def deploy_minimal_stack
    Jets::Commands::Build.new(stack_options).build_minimal_stack
    Jets::Cfn::Ship.new(stack_options).run
  end

  def deploy_full_stack
    Jets::Commands::Build.new(stack_options).build_templates
    Jets::Cfn::Ship.new(stack_options).run
  end
end
