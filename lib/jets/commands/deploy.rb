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
      deploy if first_run? # first time will deploy minimal stack
      deploy # deploy full nested stack
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end

    def deploy
      Jets::Commands::Build.new(@options).build_templates
      Jets::Cfn::Ship.new(@options).run
    end
  end
end
