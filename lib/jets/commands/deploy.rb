module Jets::Commands
  class Deploy
    include FirstRun

    def initialize(options)
      @options = options.dup
    end

    def run
      puts "Deploying project to Lambda..."
      return if @options[:noop]
      build_code
      ship if first_run? # first time will deploy minimal stack
      ship # deploy full nested stack
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end

    def ship
      merge_build_options!
      Jets::Commands::Build.new(@options).build_templates
      Jets::Cfn::Ship.new(@options).run
    end
  end
end
