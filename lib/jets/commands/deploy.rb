module Jets::Commands
  class Deploy
    include FirstRun

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
      Jets::Commands::Build.new(@options).build_code
    end

    def deploy_minimal_stack
      Jets::Commands::Build.new(@options).build_minimal_template
      Jets::Cfn::Ship.new(@options).run
    end

    def deploy_full_stack
      Jets::Commands::Build.new(@options).build_all_templates
      Jets::Cfn::Ship.new(@options).run
    end
  end
end
