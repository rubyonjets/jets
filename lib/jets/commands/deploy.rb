module Jets::Commands
  class Deploy
    include StackInfo

    def initialize(options)
      @options = options
    end

    def run
      puts "Deploying project to Lambda..."
      return if @options[:noop]
      build_code
      # first time will deploy minimal stack
      ship(stack_type: :minimal) if first_run?
      # deploy full nested stack when stack already exists
      ship(stack_type: :full, s3_bucket: s3_bucket)
    end

    def build_code
      Jets::Commands::Build.new(@options).build_code
    end

    def ship(stack_options)
      options = @options.merge(stack_options) # includes stack_type and s3_bucket
      Jets::Commands::Build.new(options).build_templates
      Jets::Cfn::Ship.new(options).run
    end
  end
end
