module Jets::Commands
  class Deploy
    include StackInfo

    def initialize(options)
      @options = options
    end

    def run
      puts "Deploying project to Lambda..."
      return if @options[:noop]
      compile_assets

      build_code
      # first time will deploy minimal stack
      ship(stack_type: :minimal) if first_run?
      # deploy full nested stack when stack already exists
      ship(stack_type: :full, s3_bucket: s3_bucket)
    end

    def compile_assets
      # Thanks: https://stackoverflow.com/questions/4195735/get-list-of-gems-being-used-by-a-bundler-project
      webpacker_loaded = Gem.loaded_specs.keys.include?("webpacker")
      return unless webpacker_loaded

      sh("yarn install")
      sh("JETS_ENV=#{Jets.env} bin/webpack")
    end

    def sh(command)
      puts "=> #{command}".colorize(:green)
      success = system(command)
      abort("#{command} failed to run") unless success
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
